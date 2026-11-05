import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlquest/shared/models/app_models.dart';

import '../../di/sql_game_providers.dart';
import '../../domain/entities/challenge_difficulty.dart';

/// Daftar challenge untuk satu filter kesulitan (reaktif).
final challengeListProvider = Provider.autoDispose
    .family<List<SqlChallengeModel>, ChallengeDifficulty>(
      (ref, difficulty) =>
          ref.watch(getChallengesProvider)(difficulty: difficulty),
    );

/// Satu challenge berdasarkan ID (reaktif); `null` bila tidak ada.
final challengeByIdProvider = Provider.autoDispose
    .family<SqlChallengeModel?, String>(
      (ref, id) => ref.watch(getChallengeByIdProvider)(id),
    );
