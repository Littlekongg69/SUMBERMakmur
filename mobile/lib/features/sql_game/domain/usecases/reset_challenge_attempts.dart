import '../repositories/sql_game_repository.dart';

/// Mengembalikan jatah percobaan sebuah challenge ke awal.
class ResetChallengeAttempts {
  const ResetChallengeAttempts(this._repository);

  final SqlGameRepository _repository;

  void call(String challengeId) => _repository.resetAttempts(challengeId);
}
