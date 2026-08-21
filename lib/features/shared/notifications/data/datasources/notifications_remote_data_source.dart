import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/api_endpoints_user.dart';
import 'package:mint_talk/core/errors/exceptions.dart';
import 'package:mint_talk/core/network/api_client.dart';
import '../models/paginated_notifications_dto.dart';

abstract class NotificationsRemoteDataSource {
  Future<PaginatedNotificationsDto> getNotifications({int? page, int? limit});
  Future<int> getUnreadCount();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}

@LazySingleton(as: NotificationsRemoteDataSource)
class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final ApiClient apiClient;

  NotificationsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<PaginatedNotificationsDto> getNotifications({int? page, int? limit}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await apiClient.get(
        ApiEndpoints.notifications,
        requiresAuth: true,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response['success'] == true || response['status'] == 'success') {
        return PaginatedNotificationsDto.fromJson(response);
      }
      throw ServerException(
        message: response['message'] ?? 'Failed to fetch notifications',
      );
    } catch (e) {
      if (e is DioException || e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.notificationsUnreadCount,
        requiresAuth: true,
      );

      if (response['success'] == true || response['status'] == 'success') {
        final data = response['data'] as Map<String, dynamic>? ?? const {};
        return data['unreadCount'] as int? ?? 0;
      }
      throw ServerException(
        message: response['message'] ?? 'Failed to fetch unread count',
      );
    } catch (e) {
      if (e is DioException || e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    final response = await apiClient.patch(
      ApiEndpoints.notificationRead(id),
      requiresAuth: true,
    );
    _ensureSuccess(response, fallbackMessage: 'Failed to mark notification as read');
  }

  @override
  Future<void> markAllAsRead() async {
    final response = await apiClient.patch(
      ApiEndpoints.notificationsReadAll,
      requiresAuth: true,
    );
    _ensureSuccess(response, fallbackMessage: 'Failed to mark all notifications as read');
  }

  void _ensureSuccess(Map<String, dynamic> response, {required String fallbackMessage}) {
    if (response['success'] == true || response['status'] == 'success') return;
    throw ServerException(message: response['message'] ?? fallbackMessage);
  }
}
