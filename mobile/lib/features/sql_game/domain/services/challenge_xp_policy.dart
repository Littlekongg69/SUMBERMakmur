import 'dart:math' as math;

import 'package:sqlquest/core/utils/sql_sandbox_engine.dart';
import 'package:sqlquest/shared/models/app_models.dart';

/// Aturan XP yang ditampilkan di UI (pratinjau sebelum jawaban dikirim).
///
/// Perhitungan XP sebenarnya tetap dilakukan oleh
/// [SqlSandboxEngine.calculateChallengeXp] agar tidak ada dua sumber kebenaran.
abstract final class ChallengeXpPolicy {
  static const double _hintPenaltyRate = 0.10;
  static const int _minHintPenaltyLabel = 1;
  static const int _maxHintPenaltyLabel = 50;

  /// Biaya XP untuk membuka satu petunjuk (untuk label tombol).
  static int hintPenalty(SqlChallengeModel challenge) {
    final raw = (challenge.xpReward * _hintPenaltyRate).round();
    return math.min(math.max(raw, _minHintPenaltyLabel), _maxHintPenaltyLabel);
  }

  /// XP yang akan didapat bila percobaan berikutnya benar.
  static int potentialXp(SqlChallengeModel challenge) {
    return SqlSandboxEngine.calculateChallengeXp(
      baseXp: challenge.xpReward,
      attemptNumber: challenge.attemptsUsed + 1,
      hintsUsed: challenge.hintsOpened,
      alreadySolvedBefore: challenge.isCompleted,
    );
  }

  /// Angka XP pada tombol. Jika tidak ada XP lagi yang bisa didapat
  /// (mis. sudah pernah selesai), tampilkan XP dasar challenge.
  static int displayedReward(SqlChallengeModel challenge) {
    final potential = potentialXp(challenge);
    return potential > 0 ? potential : challenge.xpReward;
  }
}
