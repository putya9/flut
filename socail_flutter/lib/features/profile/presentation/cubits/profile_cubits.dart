import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socail_flutter/features/profile/domain/entities/profile_user.dart';
import 'package:socail_flutter/features/profile/domain/repos/profile_repos.dart';
import 'package:socail_flutter/features/profile/presentation/cubits/profile_states.dart';
import 'package:socail_flutter/features/storage/domain/sotage_repo.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  final StorageRepo storageRepo;
  ProfileCubit({required this.profileRepo, required this.storageRepo})
      : super(ProfileInitial());

  Future<void> fetchUserProfileByUID(String uid) async {
    try {
      emit(ProfileLoading());
      final user = await profileRepo.fetchUserProfileByUID(uid);
      if (user != null) {
        emit(ProfileLoaded(profileUser: user));
      } else {
        emit(ProfileError(error: 'Пользователь не найден'));
      }
    } catch (e) {
      emit(ProfileError(error: e.toString()));
    }
  }

  Future<ProfileUser?> getUserProfile(String uid) async {
    final user = await profileRepo.fetchUserProfileByUID(uid);
    return user;
  }

  Future<void> updateProfile(
      {required String uid,
      String? newBio,
      Uint8List? imageWebBytes,
      String? mobileFilePath}) async {
    emit(ProfileLoading());
    try {
      final currentUser = await profileRepo.fetchUserProfileByUID(uid);
      if (currentUser == null) {
        emit(ProfileError(error: 'Пользователя не существует'));
        return;
      }
      String? imageDownloadURL;
      if (imageWebBytes != null || mobileFilePath != null) {
        if (mobileFilePath != null) {
          imageDownloadURL =
              await storageRepo.uploadProfileImageMobile(mobileFilePath, uid);
        } else if (imageWebBytes != null) {
          imageDownloadURL =
              await storageRepo.uploadProfileImageWeb(imageWebBytes, uid);
        }
        if (imageDownloadURL == null) {
          emit(ProfileError(error: 'Не удалось загрузить изображение'));
          return;
        }
      }
      final updatedProfile = currentUser.copyWithc(
          newBio: newBio ?? currentUser.bio,
          newProfileImageUrl: imageDownloadURL ?? currentUser.profileImageUrl);
      await profileRepo.updateProfile(updatedProfile);
      await fetchUserProfileByUID(uid);
    } catch (e) {
      emit(ProfileError(error: e.toString()));
    }
  }

  Future<void> toogleFollow(String currentUid, String targetUid) async {
    try {
      await profileRepo.toggleFollow(currentUid, targetUid);
    } catch (e) {
      emit(ProfileError(error: e.toString()));
    }
  }
}
