import 'package:flutter_test/flutter_test.dart';
import 'package:sqlquest/features/sql_game/domain/entities/challenge_difficulty.dart';

void main() {
  group('ChallengeDifficulty', () {
    test('all meloloskan semua tingkat kesulitan', () {
      for (final label in ['Easy', 'Medium', 'Hard', 'Expert', 'apa saja']) {
        expect(ChallengeDifficulty.all.matches(label), isTrue);
      }
    });

    test('filter spesifik hanya meloloskan yang cocok (tak peka huruf)', () {
      expect(ChallengeDifficulty.hard.matches('Hard'), isTrue);
      expect(ChallengeDifficulty.hard.matches('hard'), isTrue);
      expect(ChallengeDifficulty.hard.matches('Easy'), isFalse);
    });

    test('fromKey memetakan string model ke enum', () {
      expect(ChallengeDifficulty.fromKey('Expert'), ChallengeDifficulty.expert);
      expect(ChallengeDifficulty.fromKey('medium'), ChallengeDifficulty.medium);
    });

    test('fromKey nilai tak dikenal jatuh ke all', () {
      expect(ChallengeDifficulty.fromKey('???'), ChallengeDifficulty.all);
    });

    test('displayLabel all adalah "Semua Level"', () {
      expect(ChallengeDifficulty.all.displayLabel, 'Semua Level');
    });
  });
}
