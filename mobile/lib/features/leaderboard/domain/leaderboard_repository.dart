import '../../../shared/models/app_models.dart';

abstract class LeaderboardRepository {
  List<LeaderboardEntryModel> getEntries(String periodType);
}

