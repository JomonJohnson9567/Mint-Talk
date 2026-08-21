import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import '../repositories/notifications_repository.dart';

@injectable
class GetUnreadCountUseCase implements UseCase<int, NoParams> {
  final NotificationsRepository repository;

  GetUnreadCountUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(NoParams params) {
    return repository.getUnreadCount();
  }
}
