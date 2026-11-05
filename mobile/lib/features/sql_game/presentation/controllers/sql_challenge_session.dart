import 'package:sqlquest/core/utils/sql_sandbox_engine.dart';
import 'package:sqlquest/shared/models/app_models.dart';

import '../../domain/entities/block_slots.dart';
import '../../domain/entities/sql_challenge_extensions.dart';
import '../../domain/entities/sql_result_status.dart';

enum QueryInputMode { blocks, text }

/// Umpan balik dari run/submit terakhir yang ditampilkan di layar.
class QueryFeedback {
  const QueryFeedback({required this.result, this.awardedXp = 0});

  final SandboxExecutionResult result;
  final int awardedXp;

  bool get hasEarnedXp => awardedXp > 0;
}

/// State sesi pengerjaan satu challenge. Immutable.
///
/// Teks editor sengaja tidak disimpan di sini; ia dimiliki oleh
/// `TextEditingController` milik widget dan diteruskan saat run/submit.
class SqlChallengeSession {
  const SqlChallengeSession({
    required this.inputMode,
    required this.slots,
    this.feedback,
    this.remainingSeconds,
  });

  factory SqlChallengeSession.initial(SqlChallengeModel challenge) {
    return SqlChallengeSession(
      inputMode: challenge.supportsBlockMode
          ? QueryInputMode.blocks
          : QueryInputMode.text,
      slots: BlockSlots.empty(challenge.blockSlotCount),
      remainingSeconds: challenge.timeLimitSeconds,
    );
  }

  final QueryInputMode inputMode;
  final BlockSlots slots;
  final QueryFeedback? feedback;

  /// Sisa waktu dalam detik; `null` bila challenge tanpa batas waktu.
  final int? remainingSeconds;

  bool get isBlockMode => inputMode == QueryInputMode.blocks;

  bool get isTimeUp {
    final remaining = remainingSeconds;
    return remaining != null && remaining <= 0;
  }

  bool get isSolvedInSession => feedback?.result.isCorrect ?? false;

  /// Penjelasan & query referensi ditampilkan setelah challenge selesai
  /// atau percobaan habis.
  bool revealsSolutionFor(SqlChallengeModel challenge) {
    final result = feedback?.result;
    return challenge.isCompleted ||
        challenge.isAttemptsExhausted ||
        (result?.isCorrect ?? false) ||
        (result?.isAttemptsExhausted ?? false);
  }

  SqlChallengeSession copyWith({
    QueryInputMode? inputMode,
    BlockSlots? slots,
    QueryFeedback? feedback,
    bool clearFeedback = false,
    int? remainingSeconds,
  }) {
    return SqlChallengeSession(
      inputMode: inputMode ?? this.inputMode,
      slots: slots ?? this.slots,
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }
}
