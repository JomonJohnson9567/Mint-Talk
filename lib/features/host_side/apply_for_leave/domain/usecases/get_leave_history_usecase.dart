import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import '../entities/leave_history_entity.dart';
import '../repositories/leave_repository.dart';

@injectable
class GetLeaveHistoryUseCase implements UseCase<LeaveHistoryPageEntity, NoParams> {
  final LeaveRepository repository;

  GetLeaveHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, LeaveHistoryPageEntity>> call(NoParams params) {
    return repository.getLeaveHistory();
  }
}
