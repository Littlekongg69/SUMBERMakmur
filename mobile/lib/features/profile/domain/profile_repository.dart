import '../../../shared/models/app_models.dart';

abstract class ProfileRepository {
  UserProfileModel getProfile();
  List<AchievementModel> getAchievements();
}

