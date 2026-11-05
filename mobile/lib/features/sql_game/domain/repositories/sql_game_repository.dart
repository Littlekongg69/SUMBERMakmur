import 'package:sqlquest/core/utils/sql_sandbox_engine.dart';
import 'package:sqlquest/shared/models/app_models.dart';

import '../entities/challenge_submission.dart';

/// Kontrak akses data & aksi untuk fitur SQL Game.
///
/// Layer domain hanya mengenal interface ini; detail penyimpanan
/// (saat ini state in-memory aplikasi) ada di layer data.
abstract interface class SqlGameRepository {
  List<SqlChallengeModel> getChallenges();

  SqlChallengeModel? getChallengeById(String id);

  /// Menjalankan query tanpa menilai jawaban dan tanpa memakai percobaan.
  SandboxExecutionResult runQuery({
    required SqlChallengeModel challenge,
    required String query,
  });

  /// Mengirim jawaban: menilai, menghitung XP, dan memperbarui progres.
  ChallengeSubmission submitQuery({
    required String challengeId,
    required String query,
  });

  void unlockNextHint(String challengeId);

  void resetAttempts(String challengeId);
}
