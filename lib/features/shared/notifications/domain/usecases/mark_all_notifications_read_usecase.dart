import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import '../repositories/notifications_repository.dart';

@injectable
class MarkAllNotificationsReadUseCase implements UseCase<Unit, NoParams> {
  final NotificationsRepository repository;

  MarkAllNotificationsReadUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) {
    return repository.markAllAsRead();
  }
}
