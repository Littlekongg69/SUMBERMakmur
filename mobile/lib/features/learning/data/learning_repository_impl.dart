import '../../../shared/models/app_models.dart';
import '../../../shared/models/app_state_provider.dart';
import '../domain/learning_repository.dart';

/// Bagian 14 & 30: Repository Learning Path, Modul, Lesson, dan Cache Offline (MOB-04)
class LearningRepositoryImpl implements LearningRepository {
  final AppState state;

  LearningRepositoryImpl(this.state);

  @override
  List<LearningPathModel> getLearningPaths({String? query}) {
    if (query == null || query.trim().isEmpty) return state.paths;
    final q = query.trim().toLowerCase();
    return state.paths.map((p) {
      final filteredModules = p.modules.where((m) {
        final matchMod = m.title.toLowerCase().contains(q) ||
            m.description.toLowerCase().contains(q);
        final matchLesson = m.lessons.any(
          (l) =>
              l.title.toLowerCase().contains(q) ||
              l.description.toLowerCase().contains(q),
        );
        return matchMod || matchLesson;
      }).toList();
      return p.copyWith(modules: filteredModules);
    }).toList();
  }

  @override
  LessonModel? getLessonById(String id) => state.findLessonById(id);
}

