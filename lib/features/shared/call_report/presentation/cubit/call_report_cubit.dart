import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/report_call_misconduct_usecase.dart';
import 'call_report_state.dart';

@injectable
class CallReportCubit extends Cubit<CallReportState> {
  final ReportCallMisconductUseCase reportCallMisconductUseCase;

  CallReportCubit({
    required this.reportCallMisconductUseCase,
  }) : super(const CallReportInitial());

  Future<void> submitReport({
    required String callId,
    required String reason,
    required String description,
  }) async {
    emit(const CallReportSubmitting());

    final result = await reportCallMisconductUseCase(
      ReportCallParams(
        callId: callId,
        reason: reason,
        description: description,
      ),
    );

    result.fold(
      (failure) => emit(CallReportFailure(message: failure.message)),
      (report) => emit(CallReportSuccess(report: report)),
    );
  }
}
