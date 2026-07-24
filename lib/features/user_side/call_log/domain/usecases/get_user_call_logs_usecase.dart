import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/call_log_entity.dart';
import '../repositories/call_log_repository.dart';

class GetCallLogsParams extends Equatable {
  final String? status;
  final int page;
  final int limit;

  const GetCallLogsParams({
    this.status,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [status, page, limit];
}

@injectable
class GetUserCallLogsUseCase implements UseCase<List<CallLogEntity>, GetCallLogsParams> {
  final CallLogRepository repository;

  GetUserCallLogsUseCase(this.repository);

  @override
  Future<Either<Failure, List<CallLogEntity>>> call(GetCallLogsParams params) {
    return repository.getUserCallLogs(
      status: params.status,
      page: params.page,
      limit: params.limit,
    );
  }
}
