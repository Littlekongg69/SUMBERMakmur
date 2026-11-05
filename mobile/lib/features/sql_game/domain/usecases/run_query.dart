import 'package:sqlquest/core/utils/sql_sandbox_engine.dart';
import 'package:sqlquest/shared/models/app_models.dart';

import '../repositories/sql_game_repository.dart';

/// Menjalankan query hanya untuk melihat hasilnya (tidak menilai jawaban).
class RunQuery {
  const RunQuery(this._repository);

  final SqlGameRepository _repository;

  SandboxExecutionResult call({
    required SqlChallengeModel challenge,
    required String query,
  }) {
    return _repository.runQuery(challenge: challenge, query: query);
  }
}
