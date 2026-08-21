import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import '../entities/paginated_conversations_entity.dart';
import '../repositories/chat_repository.dart';

class GetConversationsParams extends Equatable {
  final int? page;
  final int? limit;

  const GetConversationsParams({this.page, this.limit});

  @override
  List<Object?> get props => [page, limit];
}

@injectable
class GetConversationsUseCase
    implements UseCase<PaginatedConversationsEntity, GetConversationsParams> {
  final ChatRepository repository;

  GetConversationsUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedConversationsEntity>> call(
    GetConversationsParams params,
  ) {
    return repository.getConversations(page: params.page, limit: params.limit);
  }
}
