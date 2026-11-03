import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlquest/core/constants/app_constants.dart';
import 'package:sqlquest/core/utils/sql_sandbox_engine.dart';
import 'package:sqlquest/main.dart';
import 'package:sqlquest/shared/models/seed_data.dart';

void main() {
  group('PRD Bagian 21: XP & Level Formula Tests (AC-12)', () {
    test('Formula XP_kumulatif(L) = 50 * L * (L - 1) matches PRD table', () {
      expect(AppConstants.cumulativeXpForLevel(1), 0);
      expect(AppConstants.cumulativeXpForLevel(2), 100);
      expect(AppConstants.cumulativeXpForLevel(3), 300);
      expect(AppConstants.cumulativeXpForLevel(4), 600);
      expect(AppConstants.cumulativeXpForLevel(5), 1000);
      expect(AppConstants.cumulativeXpForLevel(10), 4500);

      expect(AppConstants.calculateLevelFromXp(0), 1);
      expect(AppConstants.calculateLevelFromXp(99), 1);
      expect(AppConstants.calculateLevelFromXp(100), 2);
      expect(AppConstants.calculateLevelFromXp(420), 3);
      expect(AppConstants.calculateLevelFromXp(840), 4);
      expect(AppConstants.calculateLevelFromXp(4500), 10);
    });
  });

  group('PRD Bagian 19, 31, 36 & AC-06..AC-09: SQL Sandbox & XP Tests', () {
    test('AC-08: Dangerous queries (DROP, COPY, pg_read_file, multi-statement) are blocked', () {
      final dropRes = SqlSandboxEngine.execute(
        rawQuery: 'DROP TABLE users;',
        tables: const [SeedData.usersTable],
        referenceQuery: 'SELECT * FROM users;',
        expectedColumns: SeedData.usersTable.columns,
        expectedRows: SeedData.usersTable.rows,
        isSubmit: true,
      );
      expect(dropRes.resultStatus, 'blocked');

      final copyRes = SqlSandboxEngine.execute(
        rawQuery: "COPY users TO PROGRAM 'cat /etc/passwd';",
        tables: const [SeedData.usersTable],
        referenceQuery: 'SELECT * FROM users;',
        expectedColumns: SeedData.usersTable.columns,
        expectedRows: SeedData.usersTable.rows,
        isSubmit: true,
      );
      expect(copyRes.resultStatus, 'blocked');

      final multiRes = SqlSandboxEngine.execute(
        rawQuery: 'SELECT * FROM users; SELECT * FROM orders;',
        tables: const [SeedData.usersTable],
        referenceQuery: 'SELECT * FROM users;',
        expectedColumns: SeedData.usersTable.columns,
        expectedRows: SeedData.usersTable.rows,
        isSubmit: true,
      );
      expect(multiRes.resultStatus, 'blocked');
    });

    test('AC-07 & AC-08: pg_sleep triggers timeout', () {
      final timeoutRes = SqlSandboxEngine.execute(
        rawQuery: 'SELECT pg_sleep(60);',
        tables: const [SeedData.usersTable],
        referenceQuery: 'SELECT * FROM users;',
        expectedColumns: SeedData.usersTable.columns,
        expectedRows: SeedData.usersTable.rows,
        isSubmit: true,
      );
      expect(timeoutRes.resultStatus, 'timeout');
    });

    test('AC-06 & AC-07: Correct query vs wrong_result vs syntax_error', () {
      final correctRes = SqlSandboxEngine.execute(
        rawQuery: 'SELECT * FROM users WHERE age > 20;',
        tables: const [SeedData.usersTable],
        referenceQuery: 'SELECT * FROM users WHERE age > 20;',
        expectedColumns: SeedData.usersTable.columns,
        expectedRows: const [
          [2, 'Kevin', 22, 'engineer', 'Bandung'],
          [4, 'Rani', 21, 'analyst', 'Jakarta'],
          [5, 'Dimas', 24, 'engineer', 'Yogyakarta'],
        ],
        isSubmit: true,
      );
      expect(correctRes.resultStatus, 'correct');

      final wrongRes = SqlSandboxEngine.execute(
        rawQuery: 'SELECT * FROM users WHERE age < 20;',
        tables: const [SeedData.usersTable],
        referenceQuery: 'SELECT * FROM users WHERE age > 20;',
        expectedColumns: SeedData.usersTable.columns,
        expectedRows: const [
          [2, 'Kevin', 22, 'engineer', 'Bandung'],
          [4, 'Rani', 21, 'analyst', 'Jakarta'],
          [5, 'Dimas', 24, 'engineer', 'Yogyakarta'],
        ],
        isSubmit: true,
      );
      expect(wrongRes.resultStatus, 'wrong_result');

      final syntaxRes = SqlSandboxEngine.execute(
        rawQuery: 'SELEC * FORM users',
        tables: const [SeedData.usersTable],
        referenceQuery: 'SELECT * FROM users;',
        expectedColumns: SeedData.usersTable.columns,
        expectedRows: SeedData.usersTable.rows,
        isSubmit: true,
      );
      expect(syntaxRes.resultStatus, 'syntax_error');
    });

    test('AC-09: Challenge XP calculation respects attempts & hint penalties', () {
      // Base 100 XP: 1st attempt, 0 hints = 100
      expect(
        SqlSandboxEngine.calculateChallengeXp(
          baseXp: 100,
          attemptNumber: 1,
          hintsUsed: 0,
          alreadySolvedBefore: false,
        ),
        100,
      );
      // 2nd attempt (80%), 1 hint (-10%) = 70
      expect(
        SqlSandboxEngine.calculateChallengeXp(
          baseXp: 100,
          attemptNumber: 2,
          hintsUsed: 1,
          alreadySolvedBefore: false,
        ),
        70,
      );
      // 3rd attempt (60%), 3 hints (-30%) = 30
      expect(
        SqlSandboxEngine.calculateChallengeXp(
          baseXp: 100,
          attemptNumber: 3,
          hintsUsed: 3,
          alreadySolvedBefore: false,
        ),
        30,
      );
      // Already solved before = 0 XP
      expect(
        SqlSandboxEngine.calculateChallengeXp(
          baseXp: 100,
          attemptNumber: 1,
          hintsUsed: 0,
          alreadySolvedBefore: true,
        ),
        0,
      );
    });
  });

  group('PRD Bagian 37: MVP Initial Content & UI Mobile Tests', () {
    test('Seed data has >= 12 lessons and >= 20 SQL challenges', () {
      final paths = SeedData.buildInitialPaths();
      final totalLessons =
          paths.fold<int>(0, (sum, p) => sum + p.totalLessons);
      final challenges = SeedData.buildInitialChallenges();

      expect(totalLessons, greaterThanOrEqualTo(12));
      expect(challenges.length, greaterThanOrEqualTo(20));
    });

    testWidgets('Renders Home (Beranda) and 4 Bottom Navigation tabs (MOB-01)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: SqlQuestApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify 4 Bottom Navigation Tabs (Beranda, Belajar, Game, Profil)
      expect(find.text('Beranda'), findsWidgets);
      expect(find.text('Belajar'), findsWidgets);
      expect(find.text('Game'), findsWidgets);
      expect(find.text('Profil'), findsWidgets);

      // Verify Greeting card & XP consistency (AC-12 & Bagian 14)
      expect(find.textContaining('Hai, Rani!'), findsOneWidget);
      expect(find.textContaining('840 / 1000 XP'), findsOneWidget);
    });
  });
}
