import 'package:sqlquest/core/utils/sql_sandbox_engine.dart';
import 'package:sqlquest/shared/models/app_models.dart';
import 'package:sqlquest/shared/models/app_state_provider.dart';

import '../../domain/entities/challenge_submission.dart';
import '../../domain/repositories/sql_game_repository.dart';

/// Implementasi repository berbasis state in-memory aplikasi.
///
/// - Pembacaan memakai snapshot [challenges] yang diberikan saat dibuat
///   (provider membuat ulang repository setiap daftar challenge berubah).
/// - Penulisan didelegasikan ke [AppStateNotifier], yang tetap menjadi
///   pemilik aturan XP, achievement, dan misi harian.
class SqlGameRepositoryImpl implements SqlGameRepository {
  const SqlGameRepositoryImpl({
    required List<SqlChallengeModel> challenges,
    required AppStateNotifier appState,
  }) : _challenges = challenges,
       _appState = appState;

  final List<SqlChallengeModel> _challenges;
  final AppStateNotifier _appState;

  @override
  List<SqlChallengeModel> getChallenges() => _challenges;

  @override
  SqlChallengeModel? getChallengeById(String id) {
    return _challenges.where((challenge) => challenge.id == id).firstOrNull;
  }

  @override
  SandboxExecutionResult runQuery({
    required SqlChallengeModel challenge,
    required String query,
  }) {
    return SqlSandboxEngine.execute(
      rawQuery: query,
      tables: challenge.tables,
      referenceQuery: challenge.referenceQuery,
      expectedColumns: challenge.expectedColumns,
      expectedRows: challenge.expectedRows,
      ordered: challenge.ordered,
      strictColumns: challenge.strictColumns,
      allowDml: challenge.allowDml,
      isSubmit: false,
    );
  }

  @override
  ChallengeSubmission submitQuery({
    required String challengeId,
    required String query,
  }) {
    if (getChallengeById(challengeId) == null) {
      throw ArgumentError.value(
        challengeId,
        'challengeId',
        'Challenge tidak ditemukan',
      );
    }

    final outcome = _appState.submitChallengeQuery(
      challengeId: challengeId,
      query: query,
    );

    return ChallengeSubmission(
      execution: outcome.execution,
      xpAwarded: outcome.xpAwarded,
      attemptsRemaining: outcome.attemptsRemaining,
      leveledUp: outcome.leveledUp,
    );
  }

  @override
  void unlockNextHint(String challengeId) =>
      _appState.unlockNextHint(challengeId);

  @override
  void resetAttempts(String challengeId) =>
      _appState.resetChallengeAttempts(challengeId);
}
