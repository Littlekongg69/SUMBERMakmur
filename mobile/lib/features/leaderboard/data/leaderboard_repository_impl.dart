import '../../../shared/models/app_models.dart';
import '../../../shared/models/app_state_provider.dart';
import '../../../shared/models/seed_data.dart';
import '../domain/leaderboard_repository.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final AppState state;
  LeaderboardRepositoryImpl(this.state);

  @override
  List<LeaderboardEntryModel> getEntries(String periodType) {
    return SeedData.buildLeaderboard(
      currentUser: state.user,
      periodType: periodType,
    );
  }
}

