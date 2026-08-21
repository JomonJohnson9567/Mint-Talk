import 'package:equatable/equatable.dart';

class NewMessageContact extends Equatable {
  final String id;
  final String name;
  final String avatarUrl;

  const NewMessageContact({
    required this.id,
    required this.name,
    required this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, name, avatarUrl];
}

sealed class NewMessagePickerState extends Equatable {
  const NewMessagePickerState();

  @override
  List<Object?> get props => [];
}

class NewMessagePickerInitial extends NewMessagePickerState {
  const NewMessagePickerInitial();
}

class NewMessagePickerLoading extends NewMessagePickerState {
  const NewMessagePickerLoading();
}

class NewMessagePickerLoaded extends NewMessagePickerState {
  final List<NewMessageContact> contacts;

  const NewMessagePickerLoaded({required this.contacts});

  @override
  List<Object?> get props => [contacts];
}

class NewMessagePickerError extends NewMessagePickerState {
  final String message;

  const NewMessagePickerError({required this.message});

  @override
  List<Object?> get props => [message];
}
