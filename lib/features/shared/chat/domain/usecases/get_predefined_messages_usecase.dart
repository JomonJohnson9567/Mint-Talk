import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import '../entities/predefined_messages_result_entity.dart';
import '../repositories/chat_repository.dart';

@injectable
class GetPredefinedMessagesUseCase
    implements UseCase<PredefinedMessagesResultEntity, NoParams> {
  final ChatRepository repository;

  GetPredefinedMessagesUseCase(this.repository);

  @override
  Future<Either<Failure, PredefinedMessagesResultEntity>> call(NoParams params) {
    return repository.getPredefinedMessages();
  }
}
