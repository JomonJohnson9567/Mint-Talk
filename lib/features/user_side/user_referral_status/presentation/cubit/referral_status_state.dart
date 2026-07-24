import 'package:equatable/equatable.dart';

import 'package:mint_talk/features/user_side/user_referral_status/domain/entities/referral_status_entity.dart';

enum ReferralStatusLoadStatus { initial, loading, loaded, failure }

class ReferralStatusState extends Equatable {
  final ReferralStatusLoadStatus status;
  final ReferralStatusEntity? referralStatus;
  final String? errorMessage;
  final String? userId;

  const ReferralStatusState({
    this.status = ReferralStatusLoadStatus.initial,
    this.referralStatus,
    this.errorMessage,
    this.userId,
  });

  bool get isLoading => status == ReferralStatusLoadStatus.loading;

  ReferralStatusState copyWith({
    ReferralStatusLoadStatus? status,
    ReferralStatusEntity? referralStatus,
    String? Function()? errorMessage,
    String? userId,
  }) {
    return ReferralStatusState(
      status: status ?? this.status,
      referralStatus: referralStatus ?? this.referralStatus,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [status, referralStatus, errorMessage, userId];
}
