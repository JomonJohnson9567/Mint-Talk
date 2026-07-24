import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mint_talk/features/auth/data/datasources/auth_local_data_source.dart';

part 'profile_info_state.dart';

class ProfileInfoCubit extends Cubit<ProfileInfoState> {
  final AuthLocalDataSource _authLocalDataSource;

  ProfileInfoCubit(this._authLocalDataSource) : super(const ProfileInfoState());

  Future<void> loadProfileInfo() async {
    emit(state.copyWith(isLoading: true));

    final fullName = await _authLocalDataSource.getFullName();
    final phone = await _authLocalDataSource.getPhone();
    final referralCode = await _authLocalDataSource.getReferralCode();
    final imagePath = await _authLocalDataSource.getProfileImagePath();

    emit(
      state.copyWith(
        isLoading: false,
        fullName: fullName,
        phone: phone,
        referralCode: referralCode,
        imagePath: imagePath,
      ),
    );
  }
}
