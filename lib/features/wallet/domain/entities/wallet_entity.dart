import 'package:equatable/equatable.dart';

class WalletEntity extends Equatable {
  final int balance;
  final String status;

  const WalletEntity({
    required this.balance,
    required this.status,
  });

  @override
  List<Object?> get props => [balance, status];
}
