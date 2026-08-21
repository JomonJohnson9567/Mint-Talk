import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/dio_failure_mapper.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/services/socket/i_presence_socket_service.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/paginated_conversations_entity.dart';
import '../../domain/entities/paginated_messages_entity.dart';
import '../../domain/entities/predefined_messages_result_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/message_dto.dart';

@LazySingleton(as: ChatRepository)
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final IPresenceSocketService _socketService;

  ChatRepositoryImpl(this.remoteDataSource, this._socketService);

  @override
  Stream<MessageEntity> get newMessages => _socketService.newChatMessages.map(
    (json) => MessageDto.fromJson(json).toEntity(),
  );

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String recipientId,
    required String content,
    String? clientMessageId,
  }) async {
    try {
      final dto = await remoteDataSource.sendMessage(
        recipientId: recipientId,
        content: content,
        clientMessageId: clientMessageId,
      );
      return Right(dto.toEntity());
    } on DioException catch (e) {
      return Left(
        mapDioExceptionToFailure(e, fallbackMessage: 'Failed to send message'),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedConversationsEntity>> getConversations({
    int? page,
    int? limit,
  }) async {
    try {
      final dto = await remoteDataSource.getConversations(
        page: page,
        limit: limit,
      );
      return Right(dto.toEntity());
    } on DioException catch (e) {
      return Left(
        mapDioExceptionToFailure(
          e,
          fallbackMessage: 'Failed to load conversations',
        ),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedMessagesEntity>> getConversationMessages({
    required String conversationId,
    int? page,
    int? limit,
  }) async {
    try {
      final dto = await remoteDataSource.getConversationMessages(
        conversationId: conversationId,
        page: page,
        limit: limit,
      );
      return Right(dto.toEntity());
    } on DioException catch (e) {
      return Left(
        mapDioExceptionToFailure(e, fallbackMessage: 'Failed to load messages'),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markConversationRead(
    String conversationId,
  ) async {
    try {
      await remoteDataSource.markConversationRead(conversationId);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(
        mapDioExceptionToFailure(
          e,
          fallbackMessage: 'Failed to mark conversation as read',
        ),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> markMessagesDelivered(
    List<String> messageIds,
  ) async {
    try {
      final ids = await remoteDataSource.markMessagesDelivered(messageIds);
      return Right(ids);
    } on DioException catch (e) {
      return Left(
        mapDioExceptionToFailure(
          e,
          fallbackMessage: 'Failed to mark messages as delivered',
        ),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PredefinedMessagesResultEntity>>
  getPredefinedMessages() async {
    try {
      final dto = await remoteDataSource.getPredefinedMessages();
      return Right(dto.toEntity());
    } on DioException catch (e) {
      return Left(
        mapDioExceptionToFailure(
          e,
          fallbackMessage: 'Failed to load quick replies',
        ),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
