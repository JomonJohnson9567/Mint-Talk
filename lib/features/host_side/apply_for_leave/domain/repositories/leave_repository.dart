import 'package:dartz/dartz.dart';
import 'package:mint_talk/core/errors/failures.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/domain/entities/leave_request_entity.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/domain/entities/leave_history_entity.dart';

abstract class LeaveRepository {
  Future<Either<Failure, Unit>> applyForLeave(LeaveRequestEntity request);
  Future<Either<Failure, int>> getAvailableDays();
  Future<Either<Failure, LeaveHistoryPageEntity>> getLeaveHistory({
    int page = 1,
    int limit = 20,
  });
}
