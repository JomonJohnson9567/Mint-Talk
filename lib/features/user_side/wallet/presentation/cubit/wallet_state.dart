import 'package:equatable/equatable.dart';
import 'package:mint_talk/features/user_side/recharge_plans/data/models/recharge_plan_item.dart';

enum WalletStatus { 
  initial, 
  loading, 
  loaded, 
  error, 
  paymentProcessing, 
  paymentSuccess, 
  paymentFailure, 
  plansLoading, 
  plansLoaded, 
  plansError, 
  orderCreated 
}

class WalletState extends Equatable {
  final int balance;
  final List<RechargePlanItem> plans;
  final WalletStatus status;
  final String? errorMessage;
  
  // For Payment/Order flow
  final String? orderId;
  final int? amount;
  final String? key;
  final String? transactionId;

  const WalletState({
    this.balance = 0,
    this.plans = const [],
    this.status = WalletStatus.initial,
    this.errorMessage,
    this.orderId,
    this.amount,
    this.key,
    this.transactionId,
  });

  WalletState copyWith({
    int? balance,
    List<RechargePlanItem>? plans,
    WalletStatus? status,
    String? errorMessage,
    String? orderId,
    int? amount,
    String? key,
    String? transactionId,
  }) {
    return WalletState(
      balance: balance ?? this.balance,
      plans: plans ?? this.plans,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      key: key ?? this.key,
      transactionId: transactionId ?? this.transactionId,
    );
  }

  @override
  List<Object?> get props => [
        balance,
        plans,
        status,
        errorMessage,
        orderId,
        amount,
        key,
        transactionId,
      ];
}
