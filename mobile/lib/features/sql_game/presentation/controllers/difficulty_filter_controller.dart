import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/challenge_difficulty.dart';

/// Filter tingkat kesulitan yang sedang dipilih pada daftar challenge.
class DifficultyFilterController extends Notifier<ChallengeDifficulty> {
  @override
  ChallengeDifficulty build() => ChallengeDifficulty.all;

  void select(ChallengeDifficulty difficulty) => state = difficulty;
}

final difficultyFilterProvider =
    NotifierProvider.autoDispose<
      DifficultyFilterController,
      ChallengeDifficulty
    >(DifficultyFilterController.new);
