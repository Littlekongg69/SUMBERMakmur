import '../../../shared/models/app_models.dart';
import '../../../shared/models/app_state_provider.dart';
import '../domain/sql_game_repository.dart';

class SqlGameRepositoryImpl implements SqlGameRepository {
  final AppState state;
  SqlGameRepositoryImpl(this.state);

  @override
  List<SqlChallengeModel> getChallenges({String? difficulty}) {
    if (difficulty == null || difficulty == 'All') return state.challenges;
    return state.challenges
        .where((c) => c.difficulty.toLowerCase() == difficulty.toLowerCase())
        .toList();
  }

  @override
  SqlChallengeModel? getChallengeById(String id) {
    return state.challenges.cast<SqlChallengeModel?>().firstWhere(
          (c) => c!.id == id,
          orElse: () => null,
        );
  }
}

