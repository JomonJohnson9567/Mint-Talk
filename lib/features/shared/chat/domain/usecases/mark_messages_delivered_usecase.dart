import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

class MarkMessagesDeliveredParams extends Equatable {
  final List<String> messageIds;

  const MarkMessagesDeliveredParams({required this.messageIds});

  @override
  List<Object?> get props => [messageIds];
}

@injectable
class MarkMessagesDeliveredUseCase
    implements UseCase<List<String>, MarkMessagesDeliveredParams> {
  final ChatRepository repository;

  MarkMessagesDeliveredUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(MarkMessagesDeliveredParams params) {
    return repository.markMessagesDelivered(params.messageIds);
  }
}
