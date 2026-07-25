import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/usecases/usecase.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/domain/entities/leave_request_entity.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/domain/usecases/apply_for_leave_usecase.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/domain/usecases/get_available_days_usecase.dart';
import 'package:mint_talk/features/host_side/apply_for_leave/domain/usecases/get_leave_history_usecase.dart';
import 'apply_for_leave_state.dart';

@injectable
class ApplyForLeaveCubit extends Cubit<ApplyForLeaveState> {
  final ApplyForLeaveUseCase applyForLeaveUseCase;
  final GetAvailableDaysUseCase getAvailableDaysUseCase;
  final GetLeaveHistoryUseCase getLeaveHistoryUseCase;

  ApplyForLeaveCubit({
    required this.applyForLeaveUseCase,
    required this.getAvailableDaysUseCase,
    required this.getLeaveHistoryUseCase,
  }) : super(const ApplyForLeaveState()) {
    loadAvailableDays();
    loadLeaveHistory();
  }

  void changeStartDate(DateTime startDate) {
    emit(state.copyWith(
      startDate: startDate,
      status: ApplyForLeaveStatus.initial,
    ));
  }

  void changeEndDate(DateTime endDate) {
    emit(state.copyWith(
      endDate: endDate,
      status: ApplyForLeaveStatus.initial,
    ));
  }

  void changeReason(String reason) {
    emit(state.copyWith(
      reason: reason,
      status: ApplyForLeaveStatus.initial,
    ));
  }

  void changeLeaveType(String leaveType) {
    emit(state.copyWith(
      leaveType: leaveType,
      status: ApplyForLeaveStatus.initial,
    ));
  }

  Future<void> loadAvailableDays() async {
    final result = await getAvailableDaysUseCase(NoParams());
    result.fold(
      (failure) => null, // keep default available days
      (days) => emit(state.copyWith(availableDays: days)),
    );
  }

  Future<void> loadLeaveHistory() async {
    emit(state.copyWith(historyStatus: LeaveHistoryStatus.loading));
    final result = await getLeaveHistoryUseCase(NoParams());
    await result.fold<Future<void>>(
      (failure) async {
        emit(
          state.copyWith(
            historyStatus: LeaveHistoryStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (page) async {
        emit(
          state.copyWith(
            historyStatus: LeaveHistoryStatus.loaded,
            history: page.leaves,
            historyPage: page.page,
            historyTotal: page.total,
          ),
        );
      },
    );
  }

  Future<void> submitLeaveRequest() async {
    if (state.startDate == null) {
      emit(state.copyWith(
        status: ApplyForLeaveStatus.failure,
        errorMessage: 'Please select a start date',
      ));
      return;
    }
    if (state.endDate == null) {
      emit(state.copyWith(
        status: ApplyForLeaveStatus.failure,
        errorMessage: 'Please select an end date',
      ));
      return;
    }
    if (state.reason.trim().isEmpty) {
      emit(state.copyWith(
        status: ApplyForLeaveStatus.failure,
        errorMessage: 'Please provide a reason for leave',
      ));
      return;
    }
    if (state.endDate!.isBefore(state.startDate!)) {
      emit(state.copyWith(
        status: ApplyForLeaveStatus.failure,
        errorMessage: 'End date cannot be before start date',
      ));
      return;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedStart = DateTime(
      state.startDate!.year,
      state.startDate!.month,
      state.startDate!.day,
    );
    if (selectedStart.isBefore(today)) {
      emit(state.copyWith(
        status: ApplyForLeaveStatus.failure,
        errorMessage: 'Start date cannot be in the past',
      ));
      return;
    }

    emit(state.copyWith(status: ApplyForLeaveStatus.loading));

    final request = LeaveRequestEntity(
      startDate: state.startDate!,
      endDate: state.endDate!,
      reason: state.reason,
      leaveType: state.leaveType,
    );

    final result = await applyForLeaveUseCase(request);

    await result.fold<Future<void>>(
      (failure) async {
        emit(
          state.copyWith(
            status: ApplyForLeaveStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (page) async {
        emit(state.copyWith(status: ApplyForLeaveStatus.success));
        await loadLeaveHistory();
      },
    );
  }
}
