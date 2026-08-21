import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class SendMessageParams extends Equatable {
  final String recipientId;
  final String content;
  final String? clientMessageId;

  const SendMessageParams({
    required this.recipientId,
    required this.content,
    this.clientMessageId,
  });

  @override
  List<Object?> get props => [recipientId, content, clientMessageId];
}

@injectable
class SendMessageUseCase implements UseCase<MessageEntity, SendMessageParams> {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  @override
  Future<Either<Failure, MessageEntity>> call(SendMessageParams params) {
    return repository.sendMessage(
      recipientId: params.recipientId,
      content: params.content,
      clientMessageId: params.clientMessageId,
    );
  }
}
