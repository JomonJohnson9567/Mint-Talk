import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/core/network/api_client.dart';
import '../models/message_dto.dart';
import '../models/paginated_conversations_dto.dart';
import '../models/paginated_messages_dto.dart';
import '../models/predefined_messages_result_dto.dart';

abstract class ChatRemoteDataSource {
  Future<MessageDto> sendMessage({
    required String recipientId,
    required String content,
    String? clientMessageId,
  });

  Future<PaginatedConversationsDto> getConversations({int? page, int? limit});

  Future<PaginatedMessagesDto> getConversationMessages({
    required String conversationId,
    int? page,
    int? limit,
  });

  Future<void> markConversationRead(String conversationId);

  Future<List<String>> markMessagesDelivered(List<String> messageIds);

  Future<PredefinedMessagesResultDto> getPredefinedMessages();
}

@LazySingleton(as: ChatRemoteDataSource)
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient apiClient;

  ChatRemoteDataSourceImpl(this.apiClient);

  @override
  Future<MessageDto> sendMessage({
    required String recipientId,
    required String content,
    String? clientMessageId,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.chatSendMessage,
        requiresAuth: true,
        body: {
          'recipientId': recipientId,
          'content': content,
          'clientMessageId': ?clientMessageId,
        },
      );

      if (response['success'] != true) {
        throw ServerException(
          message: response['message'] ?? 'Failed to send message',
        );
      }
      return MessageDto.fromJson(response);
    } catch (e) {
      if (e is DioException || e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PaginatedConversationsDto> getConversations({
    int? page,
    int? limit,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await apiClient.get(
        ApiEndpoints.chatConversations,
        requiresAuth: true,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response['success'] != true) {
        throw ServerException(
          message: response['message'] ?? 'Failed to fetch conversations',
        );
      }
      return PaginatedConversationsDto.fromJson(response);
    } catch (e) {
      if (e is DioException || e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PaginatedMessagesDto> getConversationMessages({
    required String conversationId,
    int? page,
    int? limit,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await apiClient.get(
        ApiEndpoints.chatConversationMessages(conversationId),
        requiresAuth: true,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response['success'] != true) {
        throw ServerException(
          message: response['message'] ?? 'Failed to fetch messages',
        );
      }
      return PaginatedMessagesDto.fromJson(response);
    } catch (e) {
      if (e is DioException || e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> markConversationRead(String conversationId) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.chatConversationRead(conversationId),
        requiresAuth: true,
      );

      if (response['success'] != true) {
        throw ServerException(
          message: response['message'] ?? 'Failed to mark conversation as read',
        );
      }
    } catch (e) {
      if (e is DioException || e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<String>> markMessagesDelivered(List<String> messageIds) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.chatMessagesDelivered,
        requiresAuth: true,
        body: {'messageIds': messageIds},
      );

      if (response['success'] != true) {
        throw ServerException(
          message: response['message'] ?? 'Failed to mark messages as delivered',
        );
      }
      final data = response['data'];
      if (data is List) {
        return data.map((e) => e.toString()).toList();
      }
      return const [];
    } catch (e) {
      if (e is DioException || e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<PredefinedMessagesResultDto> getPredefinedMessages() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.chatPredefinedMessages,
        requiresAuth: true,
      );

      if (response['success'] != true) {
        throw ServerException(
          message: response['message'] ?? 'Failed to fetch predefined messages',
        );
      }
      return PredefinedMessagesResultDto.fromJson(response);
    } catch (e) {
      if (e is DioException || e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
