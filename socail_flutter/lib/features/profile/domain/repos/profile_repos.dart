import 'package:socail_flutter/features/profile/domain/entities/profile_user.dart';

abstract class ProfileRepo {
  Future<ProfileUser?> fetchUserProfileByUID(String uid);
  Future<void> updateProfile(ProfileUser updatedProfile);
  Future<void> toggleFollow(String currentUid, String targetUid);
}
