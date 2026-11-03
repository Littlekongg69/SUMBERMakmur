import '../../../shared/models/app_models.dart';

abstract class SqlGameRepository {
  List<SqlChallengeModel> getChallenges({String? difficulty});
  SqlChallengeModel? getChallengeById(String id);
}

