import '../../../core/network/dio_client.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/models/app_state_provider.dart';
import '../domain/auth_repository.dart';

/// Bagian 14 & 30: Implementasi repository Auth (Remote API /auth/* + Local state)
class AuthRepositoryImpl implements AuthRepository {
  final DioClient dioClient;
  final AppStateNotifier stateNotifier;

  AuthRepositoryImpl({
    required this.dioClient,
    required this.stateNotifier,
  });

  @override
  Future<UserProfileModel> getCurrentUser() async {
    return stateNotifier.state.user;
  }

  @override
  Future<String?> login(String email, String password) {
    return stateNotifier.login(email: email, password: password);
  }

  @override
  Future<String?> register({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) {
    return stateNotifier.register(
      email: email,
      password: password,
      username: username,
      fullName: fullName,
    );
  }

  @override
  Future<void> logout() {
    return stateNotifier.logout();
  }
}

