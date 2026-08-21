import 'package:injectable/injectable.dart';
import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

/// Continuous stream of chat messages pushed via the `new_message` socket
/// event — the live-update source for open chat threads and the
/// conversations list.
@injectable
class WatchNewMessagesUseCase {
  final ChatRepository _repository;

  WatchNewMessagesUseCase(this._repository);

  Stream<MessageEntity> call() => _repository.newMessages;
}
