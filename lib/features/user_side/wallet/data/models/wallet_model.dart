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
      balance: json['balance'] ?? 0,
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
