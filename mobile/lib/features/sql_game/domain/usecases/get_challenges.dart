import 'package:sqlquest/shared/models/app_models.dart';

import '../entities/challenge_difficulty.dart';
import '../repositories/sql_game_repository.dart';

/// Mengambil daftar challenge, opsional difilter per tingkat kesulitan.
class GetChallenges {
  const GetChallenges(this._repository);

  final SqlGameRepository _repository;

  List<SqlChallengeModel> call({
    ChallengeDifficulty difficulty = ChallengeDifficulty.all,
  }) {
    return _repository
        .getChallenges()
        .where((challenge) => difficulty.matches(challenge.difficulty))
        .toList(growable: false);
  }
}
