import 'package:socail_flutter/features/auth/domain/enties/app_user.dart';

abstract class AuthRepo {
  Future<AppUser?> loginWithEmailPassword(String email, String password);
  Future<AppUser?> registerWithEmailPassword(
      String name, String email, String password);
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
}
