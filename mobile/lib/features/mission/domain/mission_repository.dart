import '../../../shared/models/app_models.dart';

abstract class MissionRepository {
  List<DailyMissionModel> getDailyMissions();
}

