import '../../../shared/models/app_models.dart';

abstract class HomeSummaryRepository {
  UserProfileModel getUserSummary();
  List<DailyMissionModel> getDailyMissions();
}

