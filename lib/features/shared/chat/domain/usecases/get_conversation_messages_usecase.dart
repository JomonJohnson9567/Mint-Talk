import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import '../entities/paginated_messages_entity.dart';
import '../repositories/chat_repository.dart';

class GetConversationMessagesParams extends Equatable {
  final String conversationId;
  final int? page;
  final int? limit;

  const GetConversationMessagesParams({
    required this.conversationId,
    this.page,
    this.limit,
  });

  @override
  List<Object?> get props => [conversationId, page, limit];
}

@injectable
class GetConversationMessagesUseCase
    implements UseCase<PaginatedMessagesEntity, GetConversationMessagesParams> {
  final ChatRepository repository;

  GetConversationMessagesUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedMessagesEntity>> call(
    GetConversationMessagesParams params,
  ) {
    return repository.getConversationMessages(
      conversationId: params.conversationId,
      page: params.page,
      limit: params.limit,
    );
  }
}
