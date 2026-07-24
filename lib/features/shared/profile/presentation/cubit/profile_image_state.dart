import 'package:equatable/equatable.dart';

sealed class ProfileImageState extends Equatable {
  const ProfileImageState();

  @override
  List<Object?> get props => [];
}

class ProfileImageInitial extends ProfileImageState {
  const ProfileImageInitial();
}

class ProfileImageUploading extends ProfileImageState {
  const ProfileImageUploading();
}

class ProfileImageSuccess extends ProfileImageState {
  final String avatarUrl;

  const ProfileImageSuccess({required this.avatarUrl});

  @override
  List<Object?> get props => [avatarUrl];
}

class ProfileImageFailure extends ProfileImageState {
  final String message;

  const ProfileImageFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
