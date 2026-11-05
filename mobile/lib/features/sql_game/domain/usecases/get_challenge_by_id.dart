import 'package:sqlquest/shared/models/app_models.dart';

import '../repositories/sql_game_repository.dart';

/// Mengambil satu challenge; `null` bila ID tidak ditemukan.
class GetChallengeById {
  const GetChallengeById(this._repository);

  final SqlGameRepository _repository;

  SqlChallengeModel? call(String id) => _repository.getChallengeById(id);
}
