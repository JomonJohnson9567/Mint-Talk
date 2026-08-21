import 'package:equatable/equatable.dart';
import 'package:mint_talk/core/constants/user_role.dart';

sealed class AppStartState extends Equatable {
  const AppStartState();

  @override
  List<Object?> get props => [];
}

class AppStartInitial extends AppStartState {
  const AppStartInitial();
}

class AppStartLoading extends AppStartState {
  const AppStartLoading();
}

class AppStartUnauthenticated extends AppStartState {
  const AppStartUnauthenticated();
}

class AppStartNeedsProfile extends AppStartState {
  const AppStartNeedsProfile();
}

class AppStartAuthenticated extends AppStartState {
  final String? role;

  const AppStartAuthenticated({this.role});

  bool get isStaff => role.toUserRole() == UserRole.host;

  @override
  List<Object?> get props => [role];
}

class AppStartError extends AppStartState {
  final String message;

  const AppStartError({required this.message});

  @override
  List<Object?> get props => [message];
}
