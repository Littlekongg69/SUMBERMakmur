import '../../core/constants/app_constants.dart';
import '../../core/utils/sql_sandbox_engine.dart';

enum ScreenSimulatedState {
  normal,
  loading,
  empty,
  error,
  offline,
}

class UserProfileModel {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final String? avatarUrl;
  final bool emailVerified;
  final String status; // active, suspended, deleted
  final String role; // user, admin
  final String timezone;
  final String language; // 'id' or 'en'
  final String themeMode; // 'system', 'light', 'dark'
  final int totalXp;
  final int currentStreak;
  final int longestStreak;
  final List<bool> weekActiveDays; // 7 days Mon-Sun (Sen-Min)
  final int rankGlobal;
  final bool hideFromLeaderboard;
  final bool hasCompletedOnboarding;
  final String recommendedPathId;
  final int dailyGoalMinutes;
  final String reminderTime; // default '19:00'
  final DateTime? lastActivityDate;

  const UserProfileModel({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    this.avatarUrl,
    this.emailVerified = false,
    this.status = 'active',
    this.role = 'user',
    this.timezone = 'Asia/Jakarta',
    this.language = 'id',
    this.themeMode = 'light',
    this.totalXp = 840,
    this.currentStreak = 5,
    this.longestStreak = 9,
    this.weekActiveDays = const [true, true, true, true, true, false, false],
    this.rankGlobal = 12,
    this.hideFromLeaderboard = false,
    this.hasCompletedOnboarding = true,
    this.recommendedPathId = 'path-beginner',
    this.dailyGoalMinutes = 15,
    this.reminderTime = '19:00',
    this.lastActivityDate,
  });

  int get level => AppConstants.calculateLevelFromXp(totalXp);
  String get levelTitle => AppConstants.levelTitle(level);
  int get currentLevelStartXp => AppConstants.cumulativeXpForLevel(level);
  int get xpForNextLevel => AppConstants.xpForNextLevel(level);
  int get xpRemainingToNextLevel =>
      (xpForNextLevel - totalXp).clamp(0, 999999);

  double get levelProgress {
    final span = xpForNextLevel - currentLevelStartXp;
    if (span <= 0) return 1.0;
    return ((totalXp - currentLevelStartXp) / span).clamp(0.0, 1.0);
  }

  UserProfileModel copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
    String? avatarUrl,
    bool? emailVerified,
    String? status,
    String? role,
    String? timezone,
    String? language,
    String? themeMode,
    int? totalXp,
    int? currentStreak,
    int? longestStreak,
    List<bool>? weekActiveDays,
    int? rankGlobal,
    bool? hideFromLeaderboard,
    bool? hasCompletedOnboarding,
    String? recommendedPathId,
    int? dailyGoalMinutes,
    String? reminderTime,
    DateTime? lastActivityDate,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      status: status ?? this.status,
      role: role ?? this.role,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      totalXp: totalXp ?? this.totalXp,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      weekActiveDays: weekActiveDays ?? this.weekActiveDays,
      rankGlobal: rankGlobal ?? this.rankGlobal,
      hideFromLeaderboard: hideFromLeaderboard ?? this.hideFromLeaderboard,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      recommendedPathId: recommendedPathId ?? this.recommendedPathId,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      reminderTime: reminderTime ?? this.reminderTime,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
    );
  }
}

class QuizQuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;

  const QuizQuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });
}

class LessonModel {
  final String id;
  final String moduleId;
  final String pathId;
  final int position;
  final String title;
  final String description;
  final String contentMarkdown;
  final List<String> codeExamples;
  final String difficulty;
  final int estimatedMinutes;
  final int xpReward;
  final String practicePrompt;
  final String starterQuery;
  final String referenceQuery;
  final List<SandboxTable> sandboxTables;
  final List<String> expectedColumns;
  final List<List<dynamic>> expectedRows;
  final List<QuizQuestionModel> quizQuestions;
  final String status; // locked, available, in_progress, completed
  final bool hasExecutedQuery;
  final bool hasPassedQuiz;
  final int quizAttempts;

  const LessonModel({
    required this.id,
    required this.moduleId,
    required this.pathId,
    required this.position,
    required this.title,
    required this.description,
    required this.contentMarkdown,
    required this.codeExamples,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.xpReward,
    required this.practicePrompt,
    required this.starterQuery,
    required this.referenceQuery,
    required this.sandboxTables,
    required this.expectedColumns,
    required this.expectedRows,
    required this.quizQuestions,
    this.status = 'available',
    this.hasExecutedQuery = false,
    this.hasPassedQuiz = false,
    this.quizAttempts = 0,
  });

  LessonModel copyWith({
    String? status,
    bool? hasExecutedQuery,
    bool? hasPassedQuiz,
    int? quizAttempts,
  }) {
    return LessonModel(
      id: id,
      moduleId: moduleId,
      pathId: pathId,
      position: position,
      title: title,
      description: description,
      contentMarkdown: contentMarkdown,
      codeExamples: codeExamples,
      difficulty: difficulty,
      estimatedMinutes: estimatedMinutes,
      xpReward: xpReward,
      practicePrompt: practicePrompt,
      starterQuery: starterQuery,
      referenceQuery: referenceQuery,
      sandboxTables: sandboxTables,
      expectedColumns: expectedColumns,
      expectedRows: expectedRows,
      quizQuestions: quizQuestions,
      status: status ?? this.status,
      hasExecutedQuery: hasExecutedQuery ?? this.hasExecutedQuery,
      hasPassedQuiz: hasPassedQuiz ?? this.hasPassedQuiz,
      quizAttempts: quizAttempts ?? this.quizAttempts,
    );
  }
}

class ModuleModel {
  final String id;
  final String pathId;
  final int position; // Bagian 18 #3: World n = posisi modul
  final String title;
  final String description;
  final int estimatedMinutes;
  final String? prerequisiteModuleTitle;
  final List<LessonModel> lessons;

  const ModuleModel({
    required this.id,
    required this.pathId,
    required this.position,
    required this.title,
    required this.description,
    required this.estimatedMinutes,
    this.prerequisiteModuleTitle,
    required this.lessons,
  });

  String get worldLabel => 'World $position · Modul ${position.toString().padLeft(2, '0')}';

  int get completedLessons =>
      lessons.where((l) => l.status == 'completed').length;

  int get progressPercent {
    if (lessons.isEmpty) return 0;
    return ((completedLessons / lessons.length) * 100).floor();
  }

  String get status {
    if (lessons.isEmpty) return 'locked';
    if (lessons.every((l) => l.status == 'completed')) return 'completed';
    if (lessons.every((l) => l.status == 'locked')) return 'locked';
    if (lessons.any((l) =>
        l.status == 'completed' || l.status == 'in_progress')) {
      return 'in_progress';
    }
    return 'available';
  }

  LessonModel get activeOrFirstLesson {
    return lessons.firstWhere(
      (l) => l.status == 'in_progress' || l.status == 'available',
      orElse: () => lessons.first,
    );
  }

  ModuleModel copyWith({List<LessonModel>? lessons}) {
    return ModuleModel(
      id: id,
      pathId: pathId,
      position: position,
      title: title,
      description: description,
      estimatedMinutes: estimatedMinutes,
      prerequisiteModuleTitle: prerequisiteModuleTitle,
      lessons: lessons ?? this.lessons,
    );
  }
}

class LearningPathModel {
  final String id;
  final String title;
  final String description;
  final String difficulty; // Beginner, Intermediate, Advanced
  final int estimatedMinutes;
  final int xpReward;
  final String? prerequisitePathId;
  final String? prerequisiteTitle;
  final bool unlockedByOnboarding;
  final List<ModuleModel> modules;

  const LearningPathModel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.xpReward,
    this.prerequisitePathId,
    this.prerequisiteTitle,
    this.unlockedByOnboarding = false,
    required this.modules,
  });

  int get totalLessons =>
      modules.fold(0, (sum, m) => sum + m.lessons.length);

  int get completedLessons =>
      modules.fold(0, (sum, m) => sum + m.completedLessons);

  int get completedModules =>
      modules.where((m) => m.status == 'completed').length;

  int get progressPercent {
    if (totalLessons == 0) return 0;
    return ((completedLessons / totalLessons) * 100).floor();
  }

  LearningPathModel copyWith({
    bool? unlockedByOnboarding,
    List<ModuleModel>? modules,
  }) {
    return LearningPathModel(
      id: id,
      title: title,
      description: description,
      difficulty: difficulty,
      estimatedMinutes: estimatedMinutes,
      xpReward: xpReward,
      prerequisitePathId: prerequisitePathId,
      prerequisiteTitle: prerequisiteTitle,
      unlockedByOnboarding: unlockedByOnboarding ?? this.unlockedByOnboarding,
      modules: modules ?? this.modules,
    );
  }
}

enum SqlBlockType {
  keyword,
  column,
  table,
  operatorType,
  value,
  closing,
}

class SqlBlockItem {
  final String id;
  final String text;
  final SqlBlockType type;
  final bool isDistractor;

  const SqlBlockItem({
    required this.id,
    required this.text,
    required this.type,
    this.isDistractor = false,
  });
}

class SqlChallengeModel {
  final String id;
  final String title;
  final String description;
  final String storyTheme; // e.g. "SQL Cooking Quest"
  final String questContext; // e.g. "Misi #1 · Modul SELECT Dasar"
  final String objective;
  final String difficulty; // Easy, Medium, Hard, Expert
  final String inputMode; // blocks, text, both (Bagian 14)
  final int xpReward;
  final int? maxAttempts; // null = unlimited (Easy), 10 (Medium), 8 (Hard), 5 (Expert)
  final int? timeLimitSeconds; // null = no limit, 900 (15m Hard), 1200 (20m Expert)
  final List<SandboxTable> tables;
  final String schemaDdl;
  final String referenceQuery;
  final List<String> expectedColumns;
  final List<List<dynamic>> expectedRows;
  final bool ordered;
  final bool strictColumns;
  final bool allowDml;
  final List<String> hints; // max 3
  final String explanation;
  final int targetSlotCount;
  final List<SqlBlockItem> blockSet;
  final bool isCompleted;
  final int attemptsUsed;
  final int hintsOpened;

  const SqlChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    this.storyTheme = 'SQL Cooking Quest',
    this.questContext = 'Quest #1 · SQL Basics',
    required this.objective,
    required this.difficulty,
    this.inputMode = 'both',
    required this.xpReward,
    this.maxAttempts,
    this.timeLimitSeconds,
    required this.tables,
    required this.schemaDdl,
    required this.referenceQuery,
    required this.expectedColumns,
    required this.expectedRows,
    this.ordered = false,
    this.strictColumns = false,
    this.allowDml = false,
    required this.hints,
    required this.explanation,
    this.targetSlotCount = 6,
    this.blockSet = const [],
    this.isCompleted = false,
    this.attemptsUsed = 0,
    this.hintsOpened = 0,
  });

  int get remainingHearts {
    final maxH = (maxAttempts ?? 5).clamp(1, 5);
    return (maxH - attemptsUsed).clamp(0, maxH);
  }

  int get maxHeartsDisplay => (maxAttempts ?? 5).clamp(1, 5);

  bool get isAttemptsExhausted =>
      maxAttempts != null && attemptsUsed >= maxAttempts!;

  SqlChallengeModel copyWith({
    bool? isCompleted,
    int? attemptsUsed,
    int? hintsOpened,
  }) {
    return SqlChallengeModel(
      id: id,
      title: title,
      description: description,
      storyTheme: storyTheme,
      questContext: questContext,
      objective: objective,
      difficulty: difficulty,
      inputMode: inputMode,
      xpReward: xpReward,
      maxAttempts: maxAttempts,
      timeLimitSeconds: timeLimitSeconds,
      tables: tables,
      schemaDdl: schemaDdl,
      referenceQuery: referenceQuery,
      expectedColumns: expectedColumns,
      expectedRows: expectedRows,
      ordered: ordered,
      strictColumns: strictColumns,
      allowDml: allowDml,
      hints: hints,
      explanation: explanation,
      targetSlotCount: targetSlotCount,
      blockSet: blockSet,
      isCompleted: isCompleted ?? this.isCompleted,
      attemptsUsed: attemptsUsed ?? this.attemptsUsed,
      hintsOpened: hintsOpened ?? this.hintsOpened,
    );
  }
}

class DailyMissionModel {
  final String id;
  final String title;
  final String description;
  final String requirementType; // lesson_completed, challenges_completed, xp_earned, study_minutes
  final int target;
  final int progress;
  final int xpReward;
  final String difficulty; // Mudah, Sedang, Bebas
  final String status; // available, in_progress, completed, expired
  final DateTime expiresAt;
  final bool xpAwarded;

  const DailyMissionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.requirementType,
    required this.target,
    required this.progress,
    required this.xpReward,
    required this.difficulty,
    required this.status,
    required this.expiresAt,
    this.xpAwarded = false,
  });

  double get progressRatio =>
      target <= 0 ? 1.0 : (progress / target).clamp(0.0, 1.0);

  DailyMissionModel copyWith({
    int? progress,
    String? status,
    bool? xpAwarded,
  }) {
    return DailyMissionModel(
      id: id,
      title: title,
      description: description,
      requirementType: requirementType,
      target: target,
      progress: progress ?? this.progress,
      xpReward: xpReward,
      difficulty: difficulty,
      status: status ?? this.status,
      expiresAt: expiresAt,
      xpAwarded: xpAwarded ?? this.xpAwarded,
    );
  }
}

class AchievementModel {
  final String id;
  final String code;
  final String name;
  final String description;
  final String iconName;
  final int xpReward;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final bool isMvp;

  const AchievementModel({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.iconName,
    required this.xpReward,
    this.isUnlocked = false,
    this.unlockedAt,
    this.isMvp = true,
  });

  AchievementModel copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return AchievementModel(
      id: id,
      code: code,
      name: name,
      description: description,
      iconName: iconName,
      xpReward: xpReward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isMvp: isMvp,
    );
  }
}

class LeaderboardEntryModel {
  final int rank;
  final String userId;
  final String username;
  final String fullName;
  final int level;
  final int xp;
  final int rankChange; // >0 up, <0 down, 0 same
  final bool isCurrentUser;

  const LeaderboardEntryModel({
    required this.rank,
    required this.userId,
    required this.username,
    required this.fullName,
    required this.level,
    required this.xp,
    this.rankChange = 0,
    this.isCurrentUser = false,
  });
}

class AppNotificationModel {
  final String id;
  final String type; // level_up, achievement_unlocked, daily_mission
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? deepLink;

  const AppNotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.deepLink,
  });

  AppNotificationModel copyWith({bool? isRead}) {
    return AppNotificationModel(
      id: id,
      type: type,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      deepLink: deepLink,
    );
  }
}

class XpTransactionModel {
  final String id;
  final String sourceType; // lesson, quiz, challenge, mission, achievement, streak, path
  final String sourceId;
  final int amount;
  final String idempotencyKey;
  final DateTime createdAt;

  const XpTransactionModel({
    required this.id,
    required this.sourceType,
    required this.sourceId,
    required this.amount,
    required this.idempotencyKey,
    required this.createdAt,
  });
}

class AnalyticsEventModel {
  final String id;
  final String eventName;
  final String platform;
  final Map<String, dynamic> properties;
  final DateTime occurredAt;

  const AnalyticsEventModel({
    required this.id,
    required this.eventName,
    this.platform = 'android',
    required this.properties,
    required this.occurredAt,
  });
}

