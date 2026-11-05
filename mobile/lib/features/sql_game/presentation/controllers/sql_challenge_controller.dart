import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlquest/shared/models/app_models.dart';

import '../../di/sql_game_providers.dart';
import '../../domain/entities/challenge_submission.dart';
import '../../domain/entities/sql_challenge_extensions.dart';
import '../../domain/entities/sql_result_status.dart';
import 'sql_challenge_session.dart';

/// Mengelola satu sesi pengerjaan challenge: mode input, slot blok,
/// hitung mundur, serta alur run & submit.
class SqlChallengeController extends Notifier<SqlChallengeSession> {
  SqlChallengeController(this.challengeId);

  final String challengeId;
  Timer? _countdown;

  @override
  SqlChallengeSession build() {
    final challenge = _requireChallenge();
    ref.onDispose(_stopCountdown);
    if (challenge.hasTimeLimit) _startCountdown();
    return SqlChallengeSession.initial(challenge);
  }

  // ---------------------------------------------------------------- input

  void setInputMode(QueryInputMode mode) {
    state = state.copyWith(inputMode: mode);
  }

  void selectBlock(SqlBlockItem block) {
    state = state.copyWith(slots: state.slots.fillNext(block));
  }

  void removeBlockAt(int index) {
    state = state.copyWith(slots: state.slots.clearAt(index));
  }

  void clearBlocks() {
    state = state.copyWith(slots: state.slots.clear());
  }

  // ------------------------------------------------------------ run/submit

  /// Menjalankan query tanpa menilai dan tanpa memakai percobaan.
  void runQuery(String textQuery) {
    final result = ref.read(runQueryProvider)(
      challenge: _requireChallenge(),
      query: _resolveQuery(textQuery),
    );
    state = state.copyWith(feedback: QueryFeedback(result: result));
  }

  /// Mengirim jawaban. Mengembalikan `null` bila waktu sudah habis.
  ChallengeSubmission? submit(String textQuery) {
    if (state.isTimeUp) {
      state = state.copyWith(
        feedback: const QueryFeedback(result: SqlGameResults.timeUp),
      );
      return null;
    }

    final submission = ref.read(submitQueryProvider)(
      challengeId: challengeId,
      query: _resolveQuery(textQuery),
    );

    // Setelah benar, waktu tidak boleh menimpa hasil dengan "waktu habis".
    if (submission.execution.isCorrect) _stopCountdown();

    state = state.copyWith(
      feedback: QueryFeedback(
        result: submission.execution,
        awardedXp: submission.xpAwarded,
      ),
    );
    return submission;
  }

  // ----------------------------------------------------------- hint/attempt

  void unlockNextHint() => ref.read(unlockNextHintProvider)(challengeId);

  void resetAttempts() {
    ref.read(resetChallengeAttemptsProvider)(challengeId);
    state = state.copyWith(clearFeedback: true);
  }

  // ------------------------------------------------------------------ exit

  /// True bila ada jawaban yang belum dikirim dan perlu konfirmasi keluar.
  bool needsExitConfirmation(String textQuery) {
    final hasWork = state.isBlockMode
        ? state.slots.hasAny
        : textQuery.trim().isNotEmpty;
    return hasWork && !state.isSolvedInSession;
  }

  // --------------------------------------------------------------- private

  String _resolveQuery(String textQuery) =>
      state.isBlockMode ? state.slots.assembledQuery : textQuery;

  SqlChallengeModel _requireChallenge() {
    final challenge = ref.read(getChallengeByIdProvider)(challengeId);
    if (challenge == null) {
      throw StateError('Challenge "$challengeId" tidak ditemukan.');
    }
    return challenge;
  }

  void _startCountdown() {
    _countdown = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _stopCountdown() {
    _countdown?.cancel();
    _countdown = null;
  }

  void _tick() {
    final remaining = state.remainingSeconds;
    if (remaining == null) return;

    if (remaining <= 1) {
      _stopCountdown();
      state = state.copyWith(
        remainingSeconds: 0,
        feedback: const QueryFeedback(result: SqlGameResults.timeUp),
      );
    } else {
      state = state.copyWith(remainingSeconds: remaining - 1);
    }
  }
}

final sqlChallengeControllerProvider = NotifierProvider.autoDispose
    .family<SqlChallengeController, SqlChallengeSession, String>(
      SqlChallengeController.new,
    );
