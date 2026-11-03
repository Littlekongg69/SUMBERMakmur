import '../../../shared/models/app_models.dart';
import '../../../shared/models/app_state_provider.dart';
import '../domain/mission_repository.dart';

class MissionRepositoryImpl implements MissionRepository {
  final AppState state;
  MissionRepositoryImpl(this.state);

  @override
  List<DailyMissionModel> getDailyMissions() => state.dailyMissions;
}

