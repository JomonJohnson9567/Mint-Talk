import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mint_talk/core/constants/app_assets.dart';
import 'package:mint_talk/features/user_side/call_log/domain/usecases/get_host_call_logs_usecase.dart';
import 'package:mint_talk/features/user_side/call_log/domain/usecases/get_user_call_logs_usecase.dart';
import 'new_message_picker_state.dart';

@injectable
class NewMessagePickerCubit extends Cubit<NewMessagePickerState> {
  final GetHostCallLogsUseCase _getHostCallLogsUseCase;

  NewMessagePickerCubit(this._getHostCallLogsUseCase)
    : super(const NewMessagePickerInitial());

  Future<void> load() async {
    emit(const NewMessagePickerLoading());

    final result = await _getHostCallLogsUseCase(const GetCallLogsParams());

    result.fold((failure) => emit(NewMessagePickerError(message: failure.message)), (
      entries,
    ) {
      final byId = <String, NewMessageContact>{};
      for (final entry in entries) {
        final id = entry.caller?.id ?? entry.id;
        if (id.isEmpty) continue;
        byId.putIfAbsent(
          id,
          () => NewMessageContact(
            id: id,
            name: entry.caller?.fullName.isNotEmpty == true
                ? entry.caller!.fullName
                : 'User',
            avatarUrl: entry.caller?.avatarUrl.isNotEmpty == true
                ? entry.caller!.avatarUrl
                : AppAssets.femaleIcon,
          ),
        );
      }
      emit(NewMessagePickerLoaded(contacts: byId.values.toList()));
    });
  }
}
