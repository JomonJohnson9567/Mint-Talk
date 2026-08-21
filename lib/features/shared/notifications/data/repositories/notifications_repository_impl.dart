import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/dio_failure_mapper.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/services/socket/i_presence_socket_service.dart';
import 'package:mint_talk/core/utils/app_logger.dart';
import 'package:mint_talk/features/shared/notifications/domain/entities/notification_entity.dart';
import 'package:mint_talk/features/shared/notifications/domain/entities/paginated_notifications_entity.dart';
import '../datasources/notifications_remote_data_source.dart';
import '../models/notification_dto.dart';
import '../../domain/repositories/notifications_repository.dart';

@LazySingleton(as: NotificationsRepository)
class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;
  final IPresenceSocketService _presenceSocketService;

  NotificationsRepositoryImpl(this.remoteDataSource, this._presenceSocketService);

  @override
  Stream<NotificationEntity> watchNewNotifications() =>
      _presenceSocketService.newNotifications.map(NotificationDto.fromJson);

  @override
  Future<Either<Failure, PaginatedNotificationsEntity>> getNotifications({
    int? page,
    int? limit,
  }) async {
    try {
      final dto = await remoteDataSource.getNotifications(page: page, limit: limit);
      return Right(dto.toEntity());
    } on DioException catch (e, stackTrace) {
      appLogger.e(
        'NotificationsRepositoryImpl: request error loading notifications: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Failed to load notifications'));
    } catch (e, stackTrace) {
      appLogger.e(
        'NotificationsRepositoryImpl: unknown error loading notifications: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final count = await remoteDataSource.getUnreadCount();
      return Right(count);
    } on DioException catch (e, stackTrace) {
      appLogger.e(
        'NotificationsRepositoryImpl: request error loading unread count: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Failed to load unread count'));
    } catch (e, stackTrace) {
      appLogger.e(
        'NotificationsRepositoryImpl: unknown error loading unread count: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAsRead(String id) async {
    try {
      await remoteDataSource.markAsRead(id);
      return const Right(unit);
    } on DioException catch (e, stackTrace) {
      appLogger.e(
        'NotificationsRepositoryImpl: request error marking notification read: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Failed to mark as read'));
    } catch (e, stackTrace) {
      appLogger.e(
        'NotificationsRepositoryImpl: unknown error marking notification read: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();
      return const Right(unit);
    } on DioException catch (e, stackTrace) {
      appLogger.e(
        'NotificationsRepositoryImpl: request error marking all notifications read: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(mapDioExceptionToFailure(e, fallbackMessage: 'Failed to mark all as read'));
    } catch (e, stackTrace) {
      appLogger.e(
        'NotificationsRepositoryImpl: unknown error marking all notifications read: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
