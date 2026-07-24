import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/domain/repositories/leave_repository.dart';

@injectable
class GetAvailableDaysUseCase implements UseCase<int, NoParams> {
  final LeaveRepository repository;

  GetAvailableDaysUseCase(this.repository);

  @override
  Future<Either<Failure, int>> call(NoParams params) {
    return repository.getAvailableDays();
  }
}
