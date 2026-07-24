import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/upload_profile_image_usecase.dart';
import 'profile_image_state.dart';

@injectable
class ProfileImageCubit extends Cubit<ProfileImageState> {
  final UploadProfileImageUseCase uploadProfileImageUseCase;

  ProfileImageCubit({
    required this.uploadProfileImageUseCase,
  }) : super(const ProfileImageInitial());

  Future<void> uploadImage(String imagePath) async {
    emit(const ProfileImageUploading());

    final result = await uploadProfileImageUseCase(
      UploadProfileImageParams(imagePath: imagePath),
    );

    result.fold(
      (failure) => emit(ProfileImageFailure(message: failure.message)),
      (entity) => emit(ProfileImageSuccess(avatarUrl: entity.avatarUrl)),
    );
  }
}
