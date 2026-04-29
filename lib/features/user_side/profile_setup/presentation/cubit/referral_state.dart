import 'package:equatable/equatable.dart';

abstract class ReferralState extends Equatable {
  const ReferralState();

  @override
  List<Object?> get props => [];
}

class ReferralInitial extends ReferralState {}

class ReferralLoading extends ReferralState {}

class ReferralValid extends ReferralState {
  final String message;
  const ReferralValid({this.message = 'Valid code'});

  @override
  List<Object?> get props => [message];
}

class ReferralInvalid extends ReferralState {
  final String message;
  const ReferralInvalid({this.message = 'Invalid code'});

  @override
  List<Object?> get props => [message];
}
