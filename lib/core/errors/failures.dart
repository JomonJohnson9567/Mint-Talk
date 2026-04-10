import 'package:equatable/equatable.dart';

/// Base failure class for the domain layer.
/// All failures extend this so repositories return [Either<Failure, T>].
sealed class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Generic server-side error (400, 404, 500, etc.)
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

/// Network connectivity issue — device is offline or DNS failed.
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection'});
}

/// 401 / 403 after token refresh also fails — user must re-login.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message = 'Session expired. Please login again.'});
}

/// Client-side validation failure (invalid phone, OTP format, etc.)
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

/// 429 Too Many Requests — the user is rate-limited.
class RateLimitFailure extends Failure {
  const RateLimitFailure({super.message = 'Too many requests. Please wait and try again.'});
}

/// Cache failure (Failed to read/write local storage).
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}
