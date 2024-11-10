import 'package:socail_flutter/features/profile/domain/entities/profile_user.dart';

abstract class SearchRepo {
  Future<List<ProfileUser?>> searchUser(String query);
}
