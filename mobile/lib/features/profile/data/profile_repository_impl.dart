import '../../../shared/models/app_models.dart';
import '../../../shared/models/app_state_provider.dart';
import '../domain/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final AppState state;
  ProfileRepositoryImpl(this.state);

  @override
  UserProfileModel getProfile() => state.user;

  @override
  List<AchievementModel> getAchievements() => state.achievements;
}

