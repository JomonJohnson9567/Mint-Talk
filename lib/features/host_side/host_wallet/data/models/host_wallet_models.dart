import '../../domain/entities/host_wallet_entities.dart';

double _toDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

int? _toInt(Object? value) {
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

String? _nonEmpty(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

/// Display helpers for payout destinations. Everything leaving this class is
/// masked — values the API already masked pass through as-is, raw ones are
/// masked here so they never reach the UI.
abstract final class PayoutDetailsFormatter {
  static const _accountKeys = [
    'maskedAccountNumber',
    'accountNumber',
    'accountNumberMasked',
  ];
  static const _last4Keys = ['accountLast4', 'last4', 'lastFour'];
  static const _upiKeys = ['maskedUpiId', 'upiId', 'vpa'];

  /// `••••6789` from a full account number; anything ≤4 chars is fully hidden.
  static String maskAccountNumber(String value) {
    final digits = value.trim();
    if (digits.length <= 4) return '••••';
    return '••••${digits.substring(digits.length - 4)}';
  }

  /// `na•••@bank` from a full UPI ID.
  static String maskUpiId(String value) {
    final upi = value.trim();
    final at = upi.indexOf('@');
    if (at <= 0) return '•••';
    final name = upi.substring(0, at);
    final visible = name.length <= 2
        ? name.substring(0, 1)
        : name.substring(0, 2);
    return '$visible•••${upi.substring(at)}';
  }

  /// Raw values are masked even if they contain letters like `X` (a real
  /// UPI ID can) — only explicit mask glyphs count as already masked.
  static bool _looksMasked(String value) =>
      value.contains('•') || value.contains('*');

  /// The masked destination line from a `maskedDetails` (already masked) or
  /// `payoutDetails` (raw) value — either a string or an object.
  static String? describe(Object? details, {required bool alreadyMasked}) {
    if (details is String) {
      final text = details.trim();
      if (text.isEmpty) return null;
      if (alreadyMasked || _looksMasked(text)) return text;
      return text.contains('@') ? maskUpiId(text) : maskAccountNumber(text);
    }
    if (details is! Map) return null;

    for (final key in _upiKeys) {
      final value = _nonEmpty(details[key]);
      if (value != null) {
        return alreadyMasked || _looksMasked(value) ? value : maskUpiId(value);
      }
    }
    for (final key in _accountKeys) {
      final value = _nonEmpty(details[key]);
      if (value != null) {
        return alreadyMasked || _looksMasked(value)
            ? value
            : maskAccountNumber(value);
      }
    }
    for (final key in _last4Keys) {
      final value = _nonEmpty(details[key]);
      if (value != null) return '••••$value';
    }
    return null;
  }

  static String? bankName(Object? details) =>
      details is Map ? _nonEmpty(details['bankName']) : null;
}

class HostWithdrawalEntryModel extends HostWithdrawalEntryEntity {
  const HostWithdrawalEntryModel({
    required super.id,
    required super.amount,
    required super.payoutMethod,
    required super.status,
    required super.createdAt,
    super.reason,
    super.maskedDestination,
  });

  factory HostWithdrawalEntryModel.fromJson(Map<String, dynamic> json) {
    final account = json['payoutAccount'];
    final maskedDestination =
        PayoutDetailsFormatter.describe(
          json['maskedDetails'] ??
              (account is Map ? account['maskedDetails'] : null),
          alreadyMasked: true,
        ) ??
        PayoutDetailsFormatter.describe(
          json['payoutDetails'],
          alreadyMasked: false,
        );

    return HostWithdrawalEntryModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      amount: _toDouble(json['amount'] ?? json['amountINR']),
      payoutMethod: json['payoutMethod']?.toString() ?? '',
      status: WithdrawalStatus.fromApi(json['status']?.toString()),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      reason: _nonEmpty(
        json['rejectionReason'] ??
            json['failureReason'] ??
            json['reason'] ??
            json['adminNote'],
      ),
      maskedDestination: maskedDestination,
    );
  }
}

class HostWalletSummaryModel extends HostWalletSummaryEntity {
  const HostWalletSummaryModel({
    super.totalNetInr,
    super.pendingInr,
    super.processingInr,
    super.paidInr,
    super.reservedInr,
    super.legacyHeldInr,
    super.balanceMismatch,
  });

  factory HostWalletSummaryModel.fromJson(Map<String, dynamic> json) {
    return HostWalletSummaryModel(
      totalNetInr: _toDouble(
        json['totalNetINR'] ?? json['totalNetEarningsINR'],
      ),
      pendingInr: _toDouble(json['pendingINR']),
      processingInr: _toDouble(json['processingINR']),
      paidInr: _toDouble(json['paidINR']),
      reservedInr: _toDouble(json['reservedINR']),
      legacyHeldInr: _toDouble(
        json['legacyHeldINR'] ?? json['legacyApprovedINR'],
      ),
      balanceMismatch: json['balanceMismatch'] == true,
    );
  }
}

class PayoutAccountModel extends PayoutAccountEntity {
  const PayoutAccountModel({
    required super.id,
    required super.method,
    required super.label,
    required super.maskedDetail,
    required super.status,
    required super.active,
  });

  factory PayoutAccountModel.fromJson(Map<String, dynamic> json) {
    final details = json['maskedDetails'];
    final method =
        (json['payoutMethod'] ?? json['method'] ?? json['type'] ?? '')
            .toString();
    final isUpi = method == PayoutMethod.upi;
    final active = json['active'] ?? json['isActive'];

    return PayoutAccountModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      method: method,
      label: isUpi
          ? 'UPI'
          : PayoutDetailsFormatter.bankName(details) ?? 'Bank account',
      maskedDetail:
          PayoutDetailsFormatter.describe(details, alreadyMasked: true) ?? '',
      status: json['status']?.toString() ?? '',
      active: active == true,
    );
  }
}

class WithdrawalEligibilityModel extends WithdrawalEligibilityEntity {
  const WithdrawalEligibilityModel({super.eligible, super.reasons});

  /// A missing block (older backend) means "no general restriction" — the
  /// POST is still validated server-side.
  factory WithdrawalEligibilityModel.fromJson(Object? json) {
    if (json is! Map) return const WithdrawalEligibilityModel();
    final reasons = <WithdrawalIneligibilityReason>[];
    for (final reason in json['reasons'] as List? ?? const []) {
      if (reason is String && reason.isNotEmpty) {
        reasons.add(WithdrawalIneligibilityReason(code: reason));
      } else if (reason is Map) {
        final code = _nonEmpty(reason['code']);
        if (code != null) {
          reasons.add(
            WithdrawalIneligibilityReason(
              code: code,
              message: _nonEmpty(reason['message']),
            ),
          );
        }
      }
    }
    return WithdrawalEligibilityModel(
      eligible: json['eligible'] is bool
          ? json['eligible'] as bool
          : reasons.isEmpty,
      reasons: reasons,
    );
  }
}

class HostWalletOverviewModel extends HostWalletOverviewEntity {
  const HostWalletOverviewModel({
    required super.withdrawableBalance,
    required super.minWithdrawalAmount,
    required super.summary,
    required super.payoutAccounts,
    required super.eligibility,
    required super.withdrawals,
    required super.page,
    required super.limit,
    required super.total,
  });

  factory HostWalletOverviewModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>? ?? const {});
    final withdrawals = (data['withdrawals'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(HostWithdrawalEntryModel.fromJson)
        .toList();
    final accounts = (data['payoutAccounts'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(PayoutAccountModel.fromJson)
        .toList();
    final pagination = data['pagination'] is Map
        ? data['pagination'] as Map
        : data;

    return HostWalletOverviewModel(
      withdrawableBalance: _toDouble(
        data['withdrawableBalance'] ?? data['withdrawableBalanceINR'],
      ),
      minWithdrawalAmount: _toDouble(data['minWithdrawalAmount']),
      summary: HostWalletSummaryModel.fromJson(
        data['summary'] as Map<String, dynamic>? ?? const {},
      ),
      payoutAccounts: accounts,
      eligibility: WithdrawalEligibilityModel.fromJson(
        data['withdrawalEligibility'],
      ),
      withdrawals: withdrawals,
      page: _toInt(pagination['page']) ?? 1,
      limit: _toInt(pagination['limit']) ?? withdrawals.length,
      total: _toInt(pagination['total']) ?? withdrawals.length,
    );
  }
}

/// Request body — exactly `amount` and `payoutMethod`, nothing else (no host
/// id, payout details, balances or status).
class HostWithdrawalRequestModel extends HostWithdrawalRequestParams {
  const HostWithdrawalRequestModel({
    required super.amount,
    required super.payoutMethod,
  });

  Map<String, dynamic> toJson() {
    // Rupees with at most two decimals; whole amounts go out as an integer
    // (`100`, not `100.0`), matching the backend contract samples.
    final paise = (amount * 100).round();
    final num rupees = paise % 100 == 0 ? paise ~/ 100 : paise / 100;
    return {'amount': rupees, 'payoutMethod': payoutMethod};
  }
}
