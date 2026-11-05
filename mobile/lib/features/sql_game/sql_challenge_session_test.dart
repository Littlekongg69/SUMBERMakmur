import 'package:flutter_test/flutter_test.dart';
import 'package:sqlquest/core/utils/sql_sandbox_engine.dart';
import 'package:sqlquest/features/sql_game/domain/entities/sql_result_status.dart';
import 'package:sqlquest/features/sql_game/presentation/controllers/sql_challenge_session.dart';

import 'helpers/sql_game_fixtures.dart';

const _correct = SandboxExecutionResult(
  resultStatus: SqlResultStatus.correct,
  message: '',
);
const _wrong = SandboxExecutionResult(
  resultStatus: SqlResultStatus.wrongResult,
  message: '',
);
const _exhausted = SandboxExecutionResult(
  resultStatus: SqlResultStatus.attemptsExhausted,
  message: '',
);

void main() {
  group('SqlChallengeSession.initial', () {
    test('challenge dengan blockSet memulai di Mode Blok', () {
      final session = SqlChallengeSession.initial(
        buildChallenge(blockSet: [keywordSelect], targetSlotCount: 4),
      );
      expect(session.isBlockMode, isTrue);
      expect(session.slots.length, 4);
    });

    test('challenge tanpa blockSet memulai di Mode Teks', () {
      final session = SqlChallengeSession.initial(buildChallenge());
      expect(session.inputMode, QueryInputMode.text);
    });

    test('targetSlotCount <= 0 jatuh ke 6 slot', () {
      final session = SqlChallengeSession.initial(
        buildChallenge(targetSlotCount: 0, blockSet: [keywordSelect]),
      );
      expect(session.slots.length, 6);
    });

    test('sisa waktu mengikuti batas waktu challenge', () {
      expect(
        SqlChallengeSession.initial(buildChallenge(timeLimitSeconds: 900))
            .remainingSeconds,
        900,
      );
      expect(
        SqlChallengeSession.initial(buildChallenge()).remainingSeconds,
        isNull,
      );
    });
  });

  group('SqlChallengeSession.isTimeUp', () {
    test('false tanpa batas waktu', () {
      expect(SqlChallengeSession.initial(buildChallenge()).isTimeUp, isFalse);
    });

    test('true saat sisa waktu 0', () {
      final session = SqlChallengeSession.initial(
        buildChallenge(timeLimitSeconds: 60),
      ).copyWith(remainingSeconds: 0);
      expect(session.isTimeUp, isTrue);
    });
  });

  group('SqlChallengeSession.revealsSolutionFor', () {
    final base = SqlChallengeSession.initial(buildChallenge());

    test('tidak tampil di awal', () {
      expect(base.revealsSolutionFor(buildChallenge()), isFalse);
    });

    test('tampil bila challenge sudah selesai', () {
      expect(
        base.revealsSolutionFor(buildChallenge(isCompleted: true)),
        isTrue,
      );
    });

    test('tampil bila percobaan habis', () {
      expect(
        base.revealsSolutionFor(
          buildChallenge(maxAttempts: 3, attemptsUsed: 3),
        ),
        isTrue,
      );
    });

    test('tampil setelah jawaban benar di sesi ini', () {
      final session = base.copyWith(
        feedback: const QueryFeedback(result: _correct),
      );
      expect(session.revealsSolutionFor(buildChallenge()), isTrue);
    });

    test('tampil saat hasil terakhir attempts_exhausted', () {
      final session = base.copyWith(
        feedback: const QueryFeedback(result: _exhausted),
      );
      expect(session.revealsSolutionFor(buildChallenge()), isTrue);
    });

    test('tidak tampil untuk jawaban salah biasa', () {
      final session = base.copyWith(
        feedback: const QueryFeedback(result: _wrong),
      );
      expect(session.revealsSolutionFor(buildChallenge()), isFalse);
    });
  });

  group('SqlChallengeSession.copyWith', () {
    test('clearFeedback menghapus feedback', () {
      final withFeedback = SqlChallengeSession.initial(buildChallenge())
          .copyWith(feedback: const QueryFeedback(result: _wrong));
      expect(withFeedback.feedback, isNotNull);
      expect(withFeedback.copyWith(clearFeedback: true).feedback, isNull);
    });

    test('tanpa argumen mempertahankan nilai lama', () {
      final session = SqlChallengeSession.initial(
        buildChallenge(timeLimitSeconds: 30),
      ).copyWith(feedback: const QueryFeedback(result: _wrong));
      final copy = session.copyWith();
      expect(copy.remainingSeconds, 30);
      expect(copy.feedback, isNotNull);
    });
  });

  group('QueryFeedback', () {
    test('hasEarnedXp hanya true bila awardedXp > 0', () {
      expect(const QueryFeedback(result: _correct).hasEarnedXp, isFalse);
      expect(
        const QueryFeedback(result: _correct, awardedXp: 50).hasEarnedXp,
        isTrue,
      );
    });
  });
}
