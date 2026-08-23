import 'package:mint_talk/features/user_side/wallet/domain/entities/wallet_entity.dart';

class WalletModel {
  final int balance;
  final String status;

  const WalletModel({
    required this.balance,
    required this.status,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      // Backend balances can be fractional (e.g. per-second billing debits
      // partial points), so parse as num and round rather than casting
      // straight to int, which throws on a double value.
      balance: (json['balance'] as num?)?.round() ?? 0,
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'status': status,
    };
  }

  WalletEntity toEntity() => WalletEntity(balance: balance, status: status);
}
