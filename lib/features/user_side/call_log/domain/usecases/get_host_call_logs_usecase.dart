import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/call_log_entity.dart';
import '../repositories/call_log_repository.dart';
import 'get_user_call_logs_usecase.dart';

@injectable
class GetHostCallLogsUseCase implements UseCase<List<CallLogEntity>, GetCallLogsParams> {
  final CallLogRepository repository;

  GetHostCallLogsUseCase(this.repository);

  @override
  Future<Either<Failure, List<CallLogEntity>>> call(GetCallLogsParams params) {
    return repository.getHostCallLogs(
      status: params.status,
      page: params.page,
      limit: params.limit,
    );
  }
}
