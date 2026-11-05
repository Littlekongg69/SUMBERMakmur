import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlquest/shared/models/app_state_provider.dart';

import '../data/repositories/sql_game_repository_impl.dart';
import '../domain/repositories/sql_game_repository.dart';
import '../domain/usecases/get_challenge_by_id.dart';
import '../domain/usecases/get_challenges.dart';
import '../domain/usecases/reset_challenge_attempts.dart';
import '../domain/usecases/run_query.dart';
import '../domain/usecases/submit_query.dart';
import '../domain/usecases/unlock_next_hint.dart';

/// Composition root fitur SQL Game: satu-satunya tempat yang mengetahui
/// implementasi konkret repository.
///
/// Repository dibuat ulang saat daftar challenge berubah, sehingga semua
/// provider yang bergantung padanya ikut diperbarui secara reaktif.
final sqlGameRepositoryProvider = Provider<SqlGameRepository>((ref) {
  final challenges = ref.watch(appStateProvider.select((s) => s.challenges));
  return SqlGameRepositoryImpl(
    challenges: challenges,
    appState: ref.read(appStateProvider.notifier),
  );
});

final getChallengesProvider = Provider<GetChallenges>(
  (ref) => GetChallenges(ref.watch(sqlGameRepositoryProvider)),
);

final getChallengeByIdProvider = Provider<GetChallengeById>(
  (ref) => GetChallengeById(ref.watch(sqlGameRepositoryProvider)),
);

final runQueryProvider = Provider<RunQuery>(
  (ref) => RunQuery(ref.watch(sqlGameRepositoryProvider)),
);

final submitQueryProvider = Provider<SubmitQuery>(
  (ref) => SubmitQuery(ref.watch(sqlGameRepositoryProvider)),
);

final unlockNextHintProvider = Provider<UnlockNextHint>(
  (ref) => UnlockNextHint(ref.watch(sqlGameRepositoryProvider)),
);

final resetChallengeAttemptsProvider = Provider<ResetChallengeAttempts>(
  (ref) => ResetChallengeAttempts(ref.watch(sqlGameRepositoryProvider)),
);
