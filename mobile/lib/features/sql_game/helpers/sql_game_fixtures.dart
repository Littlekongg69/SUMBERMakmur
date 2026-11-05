import 'package:sqlquest/core/utils/sql_sandbox_engine.dart';
import 'package:sqlquest/features/sql_game/domain/entities/challenge_submission.dart';
import 'package:sqlquest/features/sql_game/domain/repositories/sql_game_repository.dart';
import 'package:sqlquest/shared/models/app_models.dart';

SqlChallengeModel buildChallenge({
  String id = 'c1',
  String difficulty = 'Easy',
  int xpReward = 100,
  int? maxAttempts,
  int? timeLimitSeconds,
  int attemptsUsed = 0,
  int hintsOpened = 0,
  bool isCompleted = false,
  int targetSlotCount = 6,
  List<SqlBlockItem> blockSet = const [],
}) {
  return SqlChallengeModel(
    id: id,
    title: 'Judul',
    description: 'Deskripsi',
    objective: 'Objective',
    difficulty: difficulty,
    xpReward: xpReward,
    maxAttempts: maxAttempts,
    timeLimitSeconds: timeLimitSeconds,
    tables: const [],
    schemaDdl: '',
    referenceQuery: 'SELECT 1;',
    expectedColumns: const [],
    expectedRows: const [],
    hints: const ['hint 1', 'hint 2'],
    explanation: 'Penjelasan',
    targetSlotCount: targetSlotCount,
    blockSet: blockSet,
    isCompleted: isCompleted,
    attemptsUsed: attemptsUsed,
    hintsOpened: hintsOpened,
  );
}

const keywordSelect = SqlBlockItem(
  id: 'b1',
  text: 'SELECT',
  type: SqlBlockType.keyword,
);
const columnStar = SqlBlockItem(id: 'b2', text: '*', type: SqlBlockType.column);
const tableRecipes = SqlBlockItem(
  id: 'b3',
  text: 'recipes',
  type: SqlBlockType.table,
);
const closingSemicolon = SqlBlockItem(
  id: 'b4',
  text: ';',
  type: SqlBlockType.closing,
);

/// Repository palsu untuk menguji use case tanpa AppState.
class FakeSqlGameRepository implements SqlGameRepository {
  FakeSqlGameRepository(this.challenges);

  final List<SqlChallengeModel> challenges;
  final List<String> calls = [];

  @override
  List<SqlChallengeModel> getChallenges() => challenges;

  @override
  SqlChallengeModel? getChallengeById(String id) =>
      challenges.where((c) => c.id == id).firstOrNull;

  @override
  SandboxExecutionResult runQuery({
    required SqlChallengeModel challenge,
    required String query,
  }) {
    calls.add('run:${challenge.id}:$query');
    return const SandboxExecutionResult(resultStatus: 'ok', message: 'ok');
  }

  @override
  ChallengeSubmission submitQuery({
    required String challengeId,
    required String query,
  }) {
    calls.add('submit:$challengeId:$query');
    return const ChallengeSubmission(
      execution: SandboxExecutionResult(resultStatus: 'correct', message: ''),
      xpAwarded: 80,
      attemptsRemaining: 99,
      leveledUp: false,
    );
  }

  @override
  void unlockNextHint(String challengeId) => calls.add('hint:$challengeId');

  @override
  void resetAttempts(String challengeId) => calls.add('reset:$challengeId');
}
