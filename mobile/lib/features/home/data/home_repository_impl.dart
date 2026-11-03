import '../../../shared/models/app_models.dart';
import '../../../shared/models/app_state_provider.dart';
import '../domain/home_repository.dart';

class HomeRepositoryImpl implements HomeSummaryRepository {
  final AppState state;
  HomeRepositoryImpl(this.state);

  @override
  UserProfileModel getUserSummary() => state.user;

  @override
  List<DailyMissionModel> getDailyMissions() => state.dailyMissions;
}

