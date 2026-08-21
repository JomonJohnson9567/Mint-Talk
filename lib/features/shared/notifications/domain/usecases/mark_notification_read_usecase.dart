import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import '../repositories/notifications_repository.dart';

class NotificationIdParams extends Equatable {
  final String id;

  const NotificationIdParams({required this.id});

  @override
  List<Object?> get props => [id];
}

@injectable
class MarkNotificationReadUseCase implements UseCase<Unit, NotificationIdParams> {
  final NotificationsRepository repository;

  MarkNotificationReadUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NotificationIdParams params) {
    return repository.markAsRead(params.id);
  }
}
