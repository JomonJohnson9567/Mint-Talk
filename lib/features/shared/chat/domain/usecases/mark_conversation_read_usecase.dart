import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

class MarkConversationReadParams extends Equatable {
  final String conversationId;

  const MarkConversationReadParams({required this.conversationId});

  @override
  List<Object?> get props => [conversationId];
}

@injectable
class MarkConversationReadUseCase
    implements UseCase<Unit, MarkConversationReadParams> {
  final ChatRepository repository;

  MarkConversationReadUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(MarkConversationReadParams params) {
    return repository.markConversationRead(params.conversationId);
  }
}
