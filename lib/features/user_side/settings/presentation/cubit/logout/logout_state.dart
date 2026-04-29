import 'package:equatable/equatable.dart';

enum LogoutStatus { initial, loading, success, failure }

class LogoutState extends Equatable {
  final LogoutStatus status;
  final String? errorMessage;

  const LogoutState({this.status = LogoutStatus.initial, this.errorMessage});

  LogoutState copyWith({
    LogoutStatus? status,
    String? Function()? errorMessage,
  }) {
    return LogoutState(
      status: status ?? this.status,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
