import 'package:flutter_test/flutter_test.dart';
import 'package:sqlquest/features/sql_game/domain/entities/challenge_difficulty.dart';
import 'package:sqlquest/features/sql_game/domain/usecases/get_challenge_by_id.dart';
import 'package:sqlquest/features/sql_game/domain/usecases/get_challenges.dart';
import 'package:sqlquest/features/sql_game/domain/usecases/reset_challenge_attempts.dart';
import 'package:sqlquest/features/sql_game/domain/usecases/run_query.dart';
import 'package:sqlquest/features/sql_game/domain/usecases/submit_query.dart';
import 'package:sqlquest/features/sql_game/domain/usecases/unlock_next_hint.dart';

import 'helpers/sql_game_fixtures.dart';

void main() {
  final easy = buildChallenge(id: 'e1', difficulty: 'Easy');
  final hard = buildChallenge(id: 'h1', difficulty: 'Hard');
  late FakeSqlGameRepository repository;

  setUp(() => repository = FakeSqlGameRepository([easy, hard]));

  group('GetChallenges', () {
    test('tanpa filter mengembalikan semua', () {
      expect(GetChallenges(repository)().length, 2);
    });

    test('memfilter berdasarkan tingkat kesulitan', () {
      final result = GetChallenges(repository)(
        difficulty: ChallengeDifficulty.hard,
      );
      expect(result.length, 1);
      expect(result.first.id, 'h1');
    });

    test('filter tanpa hasil mengembalikan daftar kosong', () {
      final result = GetChallenges(repository)(
        difficulty: ChallengeDifficulty.expert,
      );
      expect(result.isEmpty, isTrue);
    });
  });

  group('GetChallengeById', () {
    test('menemukan challenge yang ada', () {
      expect(GetChallengeById(repository)('h1'), hard);
    });

    test('mengembalikan null bila tidak ada', () {
      expect(GetChallengeById(repository)('nope'), isNull);
    });
  });

  group('Use case aksi mendelegasikan ke repository', () {
    test('RunQuery', () {
      final result = RunQuery(repository)(challenge: easy, query: 'Q');
      expect(result.resultStatus, 'ok');
      expect(repository.calls, ['run:e1:Q']);
    });

    test('SubmitQuery mengembalikan ChallengeSubmission', () {
      final submission = SubmitQuery(repository)(challengeId: 'e1', query: 'Q');
      expect(submission.xpAwarded, 80);
      expect(repository.calls, ['submit:e1:Q']);
    });

    test('UnlockNextHint', () {
      UnlockNextHint(repository)('e1');
      expect(repository.calls, ['hint:e1']);
    });

    test('ResetChallengeAttempts', () {
      ResetChallengeAttempts(repository)('e1');
      expect(repository.calls, ['reset:e1']);
    });
  });
}
