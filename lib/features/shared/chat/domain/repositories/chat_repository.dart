import 'package:dartz/dartz.dart';
import 'package:mint_talk/core/errors/failures.dart';
import '../entities/message_entity.dart';
import '../entities/paginated_conversations_entity.dart';
import '../entities/paginated_messages_entity.dart';
import '../entities/predefined_messages_result_entity.dart';

abstract class ChatRepository {
  /// Continuous stream of messages pushed via the `new_message` socket
  /// event — the live-update source for open chat threads and the
  /// conversations list.
  Stream<MessageEntity> get newMessages;

  Future<Either<Failure, MessageEntity>> sendMessage({
    required String recipientId,
    required String content,
    String? clientMessageId,
  });

  Future<Either<Failure, PaginatedConversationsEntity>> getConversations({
    int? page,
    int? limit,
  });

  Future<Either<Failure, PaginatedMessagesEntity>> getConversationMessages({
    required String conversationId,
    int? page,
    int? limit,
  });

  Future<Either<Failure, Unit>> markConversationRead(String conversationId);

  Future<Either<Failure, List<String>>> markMessagesDelivered(
    List<String> messageIds,
  );

  Future<Either<Failure, PredefinedMessagesResultEntity>> getPredefinedMessages();
}
