import '../repositories/sql_game_repository.dart';

/// Membuka petunjuk berikutnya (mengurangi XP yang bisa didapat).
class UnlockNextHint {
  const UnlockNextHint(this._repository);

  final SqlGameRepository _repository;

  void call(String challengeId) => _repository.unlockNextHint(challengeId);
}
