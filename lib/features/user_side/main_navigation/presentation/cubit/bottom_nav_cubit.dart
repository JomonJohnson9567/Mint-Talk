import 'package:flutter_bloc/flutter_bloc.dart';

class BottomNavCubit extends Cubit<int> {
  BottomNavCubit({int initialIndex = 1}) : super(initialIndex);

  void changeTab(int index) {
    emit(index);
  }
}
