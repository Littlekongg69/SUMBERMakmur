import '../../../shared/models/app_models.dart';

abstract class LearningRepository {
  List<LearningPathModel> getLearningPaths({String? query});
  LessonModel? getLessonById(String id);
}

