import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'host_profile_setup_state.dart';

@injectable
class HostProfileSetupCubit extends Cubit<HostProfileSetupState> {
  HostProfileSetupCubit() : super(const HostProfileSetupState());

  void nameChanged(String name) {
    emit(state.copyWith(name: name));
  }

  void dobChanged(String dob) {
    emit(state.copyWith(dob: dob));
  }

  void toggleCategory(String category) {
    final List<String> updatedCategories = List.from(state.selectedCategories);
    
    if (updatedCategories.contains(category)) {
      updatedCategories.remove(category);
    } else {
      if (updatedCategories.length < 4) {
        updatedCategories.add(category);
      }
    }
    
    emit(state.copyWith(selectedCategories: updatedCategories));
  }

  void submit() {
    if (state.name.isEmpty || state.dob.isEmpty || state.selectedCategories.isEmpty) {
      emit(state.copyWith(showErrors: true));
      return;
    }
    
    emit(state.copyWith(status: HostProfileSetupStatus.submitting));
    // Simulate successful submission
    emit(state.copyWith(status: HostProfileSetupStatus.success));
  }
}
