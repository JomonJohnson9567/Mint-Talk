import 'package:equatable/equatable.dart';

enum JoinAsHostStatus { initial, loading, success, failure }

class JoinAsHostState extends Equatable {
  final JoinAsHostStatus status;
  final String? errorMessage;

  const JoinAsHostState({
    this.status = JoinAsHostStatus.initial,
    this.errorMessage,
  });

  JoinAsHostState copyWith({
    JoinAsHostStatus? status,
    String? Function()? errorMessage,
  }) {
    return JoinAsHostState(
      status: status ?? this.status,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage];
}
