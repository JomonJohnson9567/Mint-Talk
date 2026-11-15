import 'package:equatable/equatable.dart';

/// A withdrawal POST whose outcome the app never learned (timeout, dropped
/// connection, app killed mid-request). It is kept — with its original
/// `Idempotency-Key` and body — until the server answers, so a retry can't
/// create a second withdrawal.
class PendingWithdrawalRequest extends Equatable {
  final String idempotencyKey;
  final double amount;
  final String payoutMethod;
  final DateTime createdAt;

  const PendingWithdrawalRequest({
    required this.idempotencyKey,
    required this.amount,
    required this.payoutMethod,
    required this.createdAt,
  });

  /// True when [amount]/[payoutMethod] is the exact body this key was sent
  /// with. Reusing a key with any other body is a 409 on the server.
  bool hasSameBody({required double amount, required String payoutMethod}) =>
      this.payoutMethod == payoutMethod &&
      (this.amount * 100).round() == (amount * 100).round();

  Map<String, dynamic> toJson() => {
    'idempotencyKey': idempotencyKey,
    'amount': amount,
    'payoutMethod': payoutMethod,
    'createdAt': createdAt.toIso8601String(),
  };

  static PendingWithdrawalRequest? fromJson(Map<String, dynamic> json) {
    final key = json['idempotencyKey'];
    final amount = json['amount'];
    final method = json['payoutMethod'];
    final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '');
    if (key is! String || key.isEmpty || amount is! num || method is! String) {
      return null;
    }
    return PendingWithdrawalRequest(
      idempotencyKey: key,
      amount: amount.toDouble(),
      payoutMethod: method,
      createdAt: createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  @override
  List<Object?> get props => [idempotencyKey, amount, payoutMethod, createdAt];
}
