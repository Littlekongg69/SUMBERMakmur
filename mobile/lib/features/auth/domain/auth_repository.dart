import '../../../shared/models/app_models.dart';

abstract class AuthRepository {
  Future<UserProfileModel> getCurrentUser();
  Future<String?> login(String email, String password);
  Future<String?> register({
    required String email,
    required String password,
    required String username,
    required String fullName,
  });
  Future<void> logout();
}

