import 'package:flutter_test/flutter_test.dart';
import 'package:sqlquest/features/sql_game/domain/services/challenge_xp_policy.dart';

import 'helpers/sql_game_fixtures.dart';

void main() {
  group('ChallengeXpPolicy.hintPenalty', () {
    test('10% dari XP dasar', () {
      expect(ChallengeXpPolicy.hintPenalty(buildChallenge(xpReward: 100)), 10);
    });

    test('minimal 1', () {
      expect(ChallengeXpPolicy.hintPenalty(buildChallenge(xpReward: 4)), 1);
    });

    test('maksimal 50', () {
      expect(ChallengeXpPolicy.hintPenalty(buildChallenge(xpReward: 1000)), 50);
    });
  });

  group('ChallengeXpPolicy.potentialXp', () {
    test('percobaan pertama mendapat 100%', () {
      expect(ChallengeXpPolicy.potentialXp(buildChallenge()), 100);
    });

    test('percobaan kedua 80%, ketiga dan seterusnya 60%', () {
      expect(
        ChallengeXpPolicy.potentialXp(buildChallenge(attemptsUsed: 1)),
        80,
      );
      expect(
        ChallengeXpPolicy.potentialXp(buildChallenge(attemptsUsed: 2)),
        60,
      );
      expect(
        ChallengeXpPolicy.potentialXp(buildChallenge(attemptsUsed: 7)),
        60,
      );
    });

    test('setiap hint yang dibuka memotong 10% XP dasar', () {
      expect(ChallengeXpPolicy.potentialXp(buildChallenge(hintsOpened: 2)), 80);
    });

    test('tidak pernah di bawah 10% XP dasar', () {
      final challenge = buildChallenge(attemptsUsed: 5, hintsOpened: 9);
      expect(ChallengeXpPolicy.potentialXp(challenge), 10);
    });

    test('0 bila challenge sudah pernah diselesaikan', () {
      expect(
        ChallengeXpPolicy.potentialXp(buildChallenge(isCompleted: true)),
        0,
      );
    });
  });

  group('ChallengeXpPolicy.displayedReward', () {
    test('memakai potentialXp bila > 0', () {
      expect(
        ChallengeXpPolicy.displayedReward(buildChallenge(attemptsUsed: 1)),
        80,
      );
    });

    test('jatuh ke XP dasar bila sudah selesai', () {
      expect(
        ChallengeXpPolicy.displayedReward(buildChallenge(isCompleted: true)),
        100,
      );
    });
  });
}
