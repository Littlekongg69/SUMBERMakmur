import '../entities/challenge_submission.dart';
import '../repositories/sql_game_repository.dart';

/// Mengirim jawaban challenge untuk dinilai.
class SubmitQuery {
  const SubmitQuery(this._repository);

  final SqlGameRepository _repository;

  ChallengeSubmission call({
    required String challengeId,
    required String query,
  }) {
    return _repository.submitQuery(challengeId: challengeId, query: query);
  }
}
