import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/domain/entities/leave_request_entity.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/domain/repositories/leave_repository.dart';

@injectable
class ApplyForLeaveUseCase implements UseCase<Unit, LeaveRequestEntity> {
  final LeaveRepository repository;

  ApplyForLeaveUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(LeaveRequestEntity params) {
    return repository.applyForLeave(params);
  }
}
