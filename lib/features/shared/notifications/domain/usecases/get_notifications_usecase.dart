import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import '../entities/paginated_notifications_entity.dart';
import '../repositories/notifications_repository.dart';

class GetNotificationsParams extends Equatable {
  final int? page;
  final int? limit;

  const GetNotificationsParams({this.page, this.limit});

  @override
  List<Object?> get props => [page, limit];
}

@injectable
class GetNotificationsUseCase
    implements UseCase<PaginatedNotificationsEntity, GetNotificationsParams> {
  final NotificationsRepository repository;

  GetNotificationsUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedNotificationsEntity>> call(
    GetNotificationsParams params,
  ) {
    return repository.getNotifications(page: params.page, limit: params.limit);
  }
}
