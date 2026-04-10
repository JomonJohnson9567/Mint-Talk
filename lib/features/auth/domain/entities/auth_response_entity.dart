import 'package:equatable/equatable.dart';
import 'package:mint_talk/features/auth/domain/entities/user_entity.dart';

/// Wrapper entity returned after successful OTP verification.
class AuthResponseEntity extends Equatable {
  final UserEntity user;
  final String accessToken;

  const AuthResponseEntity({
    required this.user,
    required this.accessToken,
  });

  @override
  List<Object?> get props => [user, accessToken];
}
