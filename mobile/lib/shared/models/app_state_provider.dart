import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/secure_token_storage.dart';
import '../../core/utils/sql_sandbox_engine.dart';
import 'app_models.dart';
import 'seed_data.dart';

class AppState {
  final bool isInitialized;
  final bool isAuthenticated;
  final UserProfileModel user;
  final List<LearningPathModel> paths;
  final List<SqlChallengeModel> challenges;
  final List<DailyMissionModel> dailyMissions;
  final List<AchievementModel> achievements;
  final List<AppNotificationModel> notifications;
  final List<XpTransactionModel> xpTransactions;
  final List<AnalyticsEventModel> analyticsEvents;
  final Set<String> cachedLessonIds;
  final String lastAccessedLessonId;
  final ScreenSimulatedState simulatedState;
  final int failedLoginAttempts;
  final DateTime? loginLockoutUntil;
  final bool soundEnabled;
  final bool fcmPermissionRequested;
  final bool fcmEnabled;

  const AppState({
    this.isInitialized = false,
    this.isAuthenticated = true,
    required this.user,
    required this.paths,
    required this.challenges,
    required this.dailyMissions,
    required this.achievements,
    required this.notifications,
    required this.xpTransactions,
    required this.analyticsEvents,
    this.cachedLessonIds = const {'les-1', 'les-2', 'les-3', 'les-4', 'les-5'},
    this.lastAccessedLessonId = 'les-5',
    this.simulatedState = ScreenSimulatedState.normal,
    this.failedLoginAttempts = 0,
    this.loginLockoutUntil,
    this.soundEnabled = true,
    this.fcmPermissionRequested = false,
    this.fcmEnabled = false,
  });

  AppStrings get strings => AppStrings(user.language);

  int get unreadNotificationCount =>
      notifications.where((n) => !n.isRead).length;

  LearningPathModel get activePath {
    return paths.firstWhere(
      (p) => p.id == user.recommendedPathId,
      orElse: () => paths.first,
    );
  }

  LessonModel? findLessonById(String lessonId) {
    for (final p in paths) {
      for (final m in p.modules) {
        for (final l in m.lessons) {
          if (l.id == lessonId) return l;
        }
      }
    }
    return null;
  }

  LessonModel get continueLearningLesson {
    final last = findLessonById(lastAccessedLessonId);
    if (last != null && last.status != 'completed') return last;
    for (final m in activePath.modules) {
      for (final l in m.lessons) {
        if (l.status == 'in_progress' || l.status == 'available') {
          return l;
        }
      }
    }
    return activePath.modules.first.lessons.first;
  }

  SqlChallengeModel get recommendedChallenge {
    return challenges.firstWhere(
      (c) => !c.isCompleted,
      orElse: () => challenges.first,
    );
  }

  int get totalCompletedModules =>
      paths.fold(0, (sum, p) => sum + p.completedModules);

  int get totalCompletedLessons =>
      paths.fold(0, (sum, p) => sum + p.completedLessons);

  int get totalCompletedChallenges =>
      challenges.where((c) => c.isCompleted).length;

  int get completedDailyMissionsCount =>
      dailyMissions.where((m) => m.status == 'completed').length;

  int get unlockedBadgesCount =>
      achievements.where((a) => a.isUnlocked).length;

  int get accuracyPercent => 88;

  bool isPathLocked(LearningPathModel path) {
    if (path.unlockedByOnboarding) return false;
    if (path.prerequisitePathId == null) return false;
    final prereq = paths.firstWhere(
      (p) => p.id == path.prerequisitePathId,
      orElse: () => paths.first,
    );
    return prereq.progressPercent < 100;
  }

  AppState copyWith({
    bool? isInitialized,
    bool? isAuthenticated,
    UserProfileModel? user,
    List<LearningPathModel>? paths,
    List<SqlChallengeModel>? challenges,
    List<DailyMissionModel>? dailyMissions,
    List<AchievementModel>? achievements,
    List<AppNotificationModel>? notifications,
    List<XpTransactionModel>? xpTransactions,
    List<AnalyticsEventModel>? analyticsEvents,
    Set<String>? cachedLessonIds,
    String? lastAccessedLessonId,
    ScreenSimulatedState? simulatedState,
    int? failedLoginAttempts,
    DateTime? loginLockoutUntil,
    bool clearLockout = false,
    bool? soundEnabled,
    bool? fcmPermissionRequested,
    bool? fcmEnabled,
  }) {
    return AppState(
      isInitialized: isInitialized ?? this.isInitialized,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      paths: paths ?? this.paths,
      challenges: challenges ?? this.challenges,
      dailyMissions: dailyMissions ?? this.dailyMissions,
      achievements: achievements ?? this.achievements,
      notifications: notifications ?? this.notifications,
      xpTransactions: xpTransactions ?? this.xpTransactions,
      analyticsEvents: analyticsEvents ?? this.analyticsEvents,
      cachedLessonIds: cachedLessonIds ?? this.cachedLessonIds,
      lastAccessedLessonId: lastAccessedLessonId ?? this.lastAccessedLessonId,
      simulatedState: simulatedState ?? this.simulatedState,
      failedLoginAttempts: failedLoginAttempts ?? this.failedLoginAttempts,
      loginLockoutUntil:
          clearLockout ? null : (loginLockoutUntil ?? this.loginLockoutUntil),
      soundEnabled: soundEnabled ?? this.soundEnabled,
      fcmPermissionRequested:
          fcmPermissionRequested ?? this.fcmPermissionRequested,
      fcmEnabled: fcmEnabled ?? this.fcmEnabled,
    );
  }
}

final secureTokenStorageProvider = Provider<SecureTokenStorage>((ref) {
  return SecureTokenStorage();
});

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(tokenStorage: ref.watch(secureTokenStorageProvider));
});

final appStateProvider = NotifierProvider<AppStateNotifier, AppState>(
  AppStateNotifier.new,
);

class AppStateNotifier extends Notifier<AppState> {
  final Set<String> _takenEmails = {
    'rani@mail.com',
    'dimas@mail.com',
    'suspended@mail.com',
  };
  final Set<String> _takenUsernames = {
    'rani_sql',
    'dimas_se',
    'budi_data',
    'sari_dev',
  };

  @override
  AppState build() {
    final initialUser = UserProfileModel(
      id: 'usr-rani-001',
      email: 'rani@mail.com',
      username: 'rani_sql',
      fullName: 'Rani Putri',
      emailVerified: true,
      totalXp: 840, // Level 4 (SQL Practitioner: 600..1000 XP), sesuai Mockup Bagian 14 (840 / 1.000)
      currentStreak: 5,
      longestStreak: 9,
      weekActiveDays: const [true, true, true, true, true, false, false],
      rankGlobal: 12,
      hasCompletedOnboarding: true,
      recommendedPathId: 'path-beginner',
      dailyGoalMinutes: 15,
      reminderTime: '19:00',
      lastActivityDate: DateTime.now().subtract(const Duration(days: 1)),
    );

    final initialState = AppState(
      isInitialized: true,
      isAuthenticated: true,
      user: initialUser,
      paths: SeedData.buildInitialPaths(),
      challenges: SeedData.buildInitialChallenges(),
      dailyMissions: SeedData.buildInitialMissions(),
      achievements: SeedData.buildInitialAchievements(),
      notifications: SeedData.buildInitialNotifications(),
      xpTransactions: [
        XpTransactionModel(
          id: 'xp-init-1',
          sourceType: 'lesson',
          sourceId: 'les-1',
          amount: 20,
          idempotencyKey: 'lesson_les-1',
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
        ),
        XpTransactionModel(
          id: 'xp-init-2',
          sourceType: 'challenge',
          sourceId: 'chal-2',
          amount: 20,
          idempotencyKey: 'challenge_chal-2',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ],
      analyticsEvents: const [],
    );

    _loadCachedData();
    return initialState;
  }

  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedLessons = prefs.getStringList('cached_lesson_ids');
      if (cachedLessons != null && cachedLessons.isNotEmpty) {
        state = state.copyWith(cachedLessonIds: cachedLessons.toSet());
      }
    } catch (_) {}
  }

  Future<void> cacheLessonForOffline(String lessonId) async {
    final updated = {...state.cachedLessonIds, lessonId};
    state = state.copyWith(
      cachedLessonIds: updated,
      lastAccessedLessonId: lessonId,
    );
    _recordAnalyticsEvent('lesson_started', {
      'lesson_id': lessonId,
      'path_id': state.activePath.id,
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('cached_lesson_ids', updated.toList());
      final lesson = state.findLessonById(lessonId);
      if (lesson != null) {
        await prefs.setString(
          'offline_lesson_$lessonId',
          jsonEncode({
            'id': lesson.id,
            'title': lesson.title,
            'content': lesson.contentMarkdown,
          }),
        );
      }
    } catch (_) {}
  }

  void _recordAnalyticsEvent(
    String eventName,
    Map<String, dynamic> properties,
  ) {
    final evt = AnalyticsEventModel(
      id: 'evt_${DateTime.now().microsecondsSinceEpoch}',
      eventName: eventName,
      properties: properties,
      occurredAt: DateTime.now().toUtc(),
    );
    state = state.copyWith(
      analyticsEvents: [evt, ...state.analyticsEvents],
    );
  }

  /// Bagian 21 & AC-12: Mencatat transaksi XP immutable dengan idempotency_key
  bool _awardXp({
    required String sourceType,
    required String sourceId,
    required int amount,
    required String idempotencyKey,
  }) {
    if (amount <= 0) return false;
    final alreadyExists = state.xpTransactions.any(
      (tx) =>
          tx.idempotencyKey == idempotencyKey ||
          (tx.sourceType == sourceType &&
              tx.sourceId == sourceId &&
              sourceType != 'streak'),
    );
    if (alreadyExists) return false;

    final prevLevel = state.user.level;
    final newTotalXp = state.user.totalXp + amount;
    final tx = XpTransactionModel(
      id: 'xp_${DateTime.now().microsecondsSinceEpoch}',
      sourceType: sourceType,
      sourceId: sourceId,
      amount: amount,
      idempotencyKey: idempotencyKey,
      createdAt: DateTime.now().toUtc(),
    );

    final updatedUser = state.user.copyWith(totalXp: newTotalXp);
    final newLevel = updatedUser.level;

    var updatedNotifications = List<AppNotificationModel>.from(
      state.notifications,
    );

    if (newLevel > prevLevel) {
      updatedNotifications.insert(
        0,
        AppNotificationModel(
          id: 'notif_lvl_${DateTime.now().microsecondsSinceEpoch}',
          type: 'level_up',
          title:
              'Level Up! Kamu naik ke Level $newLevel (${AppConstants.levelTitle(newLevel)})',
          body: 'Total XP kamu kini $newTotalXp XP. Pertahankan semangat belajarmu!',
          createdAt: DateTime.now(),
          deepLink: '/profile',
        ),
      );
      _recordAnalyticsEvent('level_up', {'new_level': newLevel});
    }

    state = state.copyWith(
      user: updatedUser,
      xpTransactions: [tx, ...state.xpTransactions],
      notifications: updatedNotifications,
    );

    // Update daily mission progress for xp_earned
    _incrementMissionProgress('xp_earned', amount);
    return newLevel > prevLevel;
  }

  /// Bagian 22 & AC-11: Evaluasi Streak sekali per hari lokal
  void _recordValidLearningActivity() {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final lastDate = state.user.lastActivityDate != null
        ? DateTime(
            state.user.lastActivityDate!.year,
            state.user.lastActivityDate!.month,
            state.user.lastActivityDate!.day,
          )
        : null;

    if (lastDate != null && lastDate.isAtSameMomentAs(todayDate)) {
      // Aktivitas kedua di hari yang sama tidak menambah streak (AC-11)
      return;
    }

    int newStreak;
    if (lastDate != null &&
        todayDate.difference(lastDate).inDays == 1) {
      newStreak = state.user.currentStreak + 1;
    } else if (lastDate == null) {
      newStreak = state.user.currentStreak + 1;
    } else {
      newStreak = 1;
    }

    final newLongest = newStreak > state.user.longestStreak
        ? newStreak
        : state.user.longestStreak;

    final weekdayIdx = (now.weekday - 1).clamp(0, 6);
    final updatedWeek = List<bool>.from(state.user.weekActiveDays);
    updatedWeek[weekdayIdx] = true;

    state = state.copyWith(
      user: state.user.copyWith(
        currentStreak: newStreak,
        longestStreak: newLongest,
        weekActiveDays: updatedWeek,
        lastActivityDate: todayDate,
      ),
    );
    _recordAnalyticsEvent('streak_extended', {'current_streak': newStreak});

    if (newStreak >= 7) {
      _unlockAchievement('streak_7');
    }
  }

  void _incrementMissionProgress(String requirementType, int delta) {
    final updated = <DailyMissionModel>[];
    var notifications = List<AppNotificationModel>.from(state.notifications);

    for (final m in state.dailyMissions) {
      if (m.requirementType == requirementType && m.status != 'completed') {
        final nextProg = (m.progress + delta).clamp(0, m.target);
        final isNowCompleted = nextProg >= m.target;
        final nextStatus = isNowCompleted ? 'completed' : 'in_progress';
        if (m.progress == 0 && nextProg > 0) {
          _recordAnalyticsEvent('mission_started', {'mission_id': m.id});
        }
        updated.add(
          m.copyWith(
            progress: nextProg,
            status: nextStatus,
            xpAwarded: isNowCompleted ? true : m.xpAwarded,
          ),
        );
        if (isNowCompleted && !m.xpAwarded) {
          notifications.insert(
            0,
            AppNotificationModel(
              id: 'notif_mis_${DateTime.now().microsecondsSinceEpoch}',
              type: 'daily_mission',
              title: 'Misi Harian Selesai: ${m.title}',
              body: 'Kamu mendapatkan +${m.xpReward} XP dari misi harian!',
              createdAt: DateTime.now(),
              deepLink: '/missions',
            ),
          );
          _recordAnalyticsEvent('mission_completed', {
            'mission_id': m.id,
            'xp_awarded': m.xpReward,
          });
        }
      } else {
        updated.add(m);
      }
    }

    state = state.copyWith(
      dailyMissions: updated,
      notifications: notifications,
    );
  }

  void _unlockAchievement(String code) {
    final idx = state.achievements.indexWhere((a) => a.code == code);
    if (idx == -1) return;
    final ach = state.achievements[idx];
    if (ach.isUnlocked) return;

    final updatedList = List<AchievementModel>.from(state.achievements);
    updatedList[idx] = ach.copyWith(
      isUnlocked: true,
      unlockedAt: DateTime.now(),
    );

    final notif = AppNotificationModel(
      id: 'notif_ach_${DateTime.now().microsecondsSinceEpoch}',
      type: 'achievement_unlocked',
      title: 'Achievement Terbuka: ${ach.name}!',
      body: '${ach.description} (+${ach.xpReward} XP)',
      createdAt: DateTime.now(),
      deepLink: '/achievements',
    );

    state = state.copyWith(
      achievements: updatedList,
      notifications: [notif, ...state.notifications],
    );

    _awardXp(
      sourceType: 'achievement',
      sourceId: ach.id,
      amount: ach.xpReward,
      idempotencyKey: 'ach_${ach.code}',
    );
    _recordAnalyticsEvent('achievement_unlocked', {'achievement_code': code});
  }

  /// AC-01: Register dengan email, password (>=8 karakter, huruf & angka), username unik 3-20 karakter
  Future<String?> register({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanUser = username.trim().toLowerCase();
    final cleanName = fullName.trim();

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(cleanEmail)) {
      return 'EMAIL_INVALID: Format email tidak valid.';
    }
    if (_takenEmails.contains(cleanEmail)) {
      return 'EMAIL_TAKEN: Email sudah terdaftar.';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(cleanUser)) {
      return 'USERNAME_INVALID: Username wajib 3–20 karakter (huruf, angka, atau _).';
    }
    if (_takenUsernames.contains(cleanUser)) {
      return 'USERNAME_TAKEN: Username sudah dipakai pengguna lain.';
    }
    if (password.length < 8 ||
        !RegExp(r'[A-Za-z]').hasMatch(password) ||
        !RegExp(r'\d').hasMatch(password)) {
      return 'PASSWORD_WEAK: Password minimal 8 karakter dan wajib memuat huruf serta angka.';
    }

    _takenEmails.add(cleanEmail);
    _takenUsernames.add(cleanUser);

    final newUser = UserProfileModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: cleanEmail,
      username: cleanUser,
      fullName: cleanName.isEmpty ? cleanUser : cleanName,
      emailVerified: false, // FR-AUTH-02: akun baru belum terverifikasi, pengingat tampil di Home
      totalXp: 0,
      currentStreak: 0,
      longestStreak: 0,
      weekActiveDays: const [false, false, false, false, false, false, false],
      rankGlobal: 50,
      hasCompletedOnboarding: false,
      recommendedPathId: 'path-beginner',
      dailyGoalMinutes: 15,
      reminderTime: '19:00',
    );

    await ref.read(secureTokenStorageProvider).saveTokens(
          accessToken: 'jwt_access_${newUser.id}',
          refreshToken: 'opaque_refresh_${newUser.id}',
          userId: newUser.id,
        );

    state = state.copyWith(
      isAuthenticated: true,
      user: newUser,
      failedLoginAttempts: 0,
      clearLockout: true,
    );
    _recordAnalyticsEvent('user_registered', {'method': 'email'});
    return null;
  }

  /// AC-02: Login dengan pembatasan 5 gagal per 15 menit (429) & pemeriksaan ACCOUNT_SUSPENDED
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final now = DateTime.now();
    if (state.loginLockoutUntil != null &&
        now.isBefore(state.loginLockoutUntil!)) {
      final mins = state.loginLockoutUntil!.difference(now).inMinutes + 1;
      return 'TOO_MANY_ATTEMPTS: Terlalu banyak percobaan gagal (429). Silakan tunggu $mins menit.';
    }

    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail == 'suspended@mail.com') {
      return 'ACCOUNT_SUSPENDED: Akun kamu sedang ditangguhkan oleh moderator (403).';
    }

    if (password.length < 8 || password == 'wrongpass') {
      final nextFails = state.failedLoginAttempts + 1;
      if (nextFails >= 5) {
        state = state.copyWith(
          failedLoginAttempts: nextFails,
          loginLockoutUntil: now.add(const Duration(minutes: 15)),
        );
        return 'TOO_MANY_ATTEMPTS: 5 kali gagal login (429). Silakan tunggu 15 menit.';
      }
      state = state.copyWith(failedLoginAttempts: nextFails);
      return 'INVALID_CREDENTIALS: Email atau password salah (${5 - nextFails} kesempatan tersisa).';
    }

    final updatedUser = state.user.copyWith(
      email: cleanEmail,
      status: 'active',
    );

    await ref.read(secureTokenStorageProvider).saveTokens(
          accessToken: 'jwt_access_${updatedUser.id}',
          refreshToken: 'opaque_refresh_${updatedUser.id}',
          userId: updatedUser.id,
        );

    state = state.copyWith(
      isAuthenticated: true,
      user: updatedUser,
      failedLoginAttempts: 0,
      clearLockout: true,
    );
    _recordAnalyticsEvent('user_login', {'method': 'email'});
    return null;
  }

  /// AC-03: Login Google OAuth
  Future<void> loginWithGoogle({bool isNewUser = false}) async {
    final updatedUser = state.user.copyWith(
      emailVerified: true,
      hasCompletedOnboarding: !isNewUser,
    );
    await ref.read(secureTokenStorageProvider).saveTokens(
          accessToken: 'jwt_google_${updatedUser.id}',
          refreshToken: 'opaque_google_${updatedUser.id}',
          userId: updatedUser.id,
        );
    state = state.copyWith(
      isAuthenticated: true,
      user: updatedUser,
      failedLoginAttempts: 0,
      clearLockout: true,
    );
    _recordAnalyticsEvent('user_login', {'method': 'google'});
  }

  /// AC-04 & Bagian 12: Onboarding 4 pertanyaan
  void completeOnboarding({
    required String sqlLevel, // Belum pernah, Dasar, Menengah, Mahir
    required String dbExperience,
    required String learningGoal,
    required int dailyGoalMinutes,
  }) {
    String recommendedPathId = 'path-beginner';
    bool unlockIntermediate = false;
    bool unlockAdvanced = false;

    if (sqlLevel == 'Menengah') {
      recommendedPathId = 'path-intermediate';
      unlockIntermediate = true;
    } else if (sqlLevel == 'Mahir') {
      recommendedPathId = 'path-advanced';
      unlockIntermediate = true;
      unlockAdvanced = true;
    }

    final updatedPaths = state.paths.map((p) {
      if (p.id == 'path-intermediate' && unlockIntermediate) {
        return p.copyWith(unlockedByOnboarding: true);
      }
      if (p.id == 'path-advanced' && unlockAdvanced) {
        return p.copyWith(unlockedByOnboarding: true);
      }
      return p;
    }).toList();

    state = state.copyWith(
      user: state.user.copyWith(
        hasCompletedOnboarding: true,
        recommendedPathId: recommendedPathId,
        dailyGoalMinutes: dailyGoalMinutes,
        reminderTime: '19:00',
      ),
      paths: updatedPaths,
    );
  }

  void skipOnboarding() {
    state = state.copyWith(
      user: state.user.copyWith(
        hasCompletedOnboarding: true,
        recommendedPathId: 'path-beginner',
        dailyGoalMinutes: 15,
        reminderTime: '19:00',
      ),
    );
  }

  void verifyEmailNow() {
    state = state.copyWith(
      user: state.user.copyWith(emailVerified: true),
    );
  }

  /// MOB-05: Kontekstual izin Push Notification setelah onboarding
  void setFcmPermission(bool granted) {
    state = state.copyWith(
      fcmPermissionRequested: true,
      fcmEnabled: granted,
    );
  }

  /// Tandai query latihan pada lesson sudah dieksekusi
  void markLessonQueryExecuted(String lessonId) {
    _updateLesson(lessonId, (lesson) {
      return lesson.copyWith(
        hasExecutedQuery: true,
        status: lesson.status == 'completed' ? 'completed' : 'in_progress',
      );
    });
    _unlockAchievement('first_sql_query');
  }

  /// Submit kuis lesson (Bagian 17: skor lulus >= 70%, maks 3 percobaan untuk XP)
  ({bool passed, int xpAwarded, int scorePercent}) submitLessonQuiz({
    required String lessonId,
    required int scorePercent,
  }) {
    final lesson = state.findLessonById(lessonId);
    if (lesson == null) {
      return (passed: false, xpAwarded: 0, scorePercent: scorePercent);
    }

    final nextAttempts = lesson.quizAttempts + 1;
    final passed = scorePercent >= 70;
    _recordAnalyticsEvent('quiz_completed', {
      'quiz_id': 'quiz_$lessonId',
      'score': scorePercent,
      'passed': passed,
    });

    int quizXp = 0;
    if (passed && !lesson.hasPassedQuiz && nextAttempts <= 3) {
      // Bagian 21: 10 + 1 per 10% skor di atas 70% (maks 20)
      final bonus = ((scorePercent - 70) ~/ 10).clamp(0, 10);
      quizXp = 10 + bonus;
      _awardXp(
        sourceType: 'quiz',
        sourceId: 'quiz_$lessonId',
        amount: quizXp,
        idempotencyKey: 'quiz_$lessonId',
      );
    }

    _updateLesson(lessonId, (l) {
      return l.copyWith(
        quizAttempts: nextAttempts,
        hasPassedQuiz: l.hasPassedQuiz || passed,
      );
    });

    if (passed) {
      _recordValidLearningActivity();
    }

    return (passed: passed, xpAwarded: quizXp, scorePercent: scorePercent);
  }

  /// AC-05: Menyelesaikan Lesson (memberi XP satu kali saja & membuka lesson berikutnya)
  ({bool success, String message, int xpAwarded, bool leveledUp})
      completeLesson(String lessonId) {
    final lesson = state.findLessonById(lessonId);
    if (lesson == null) {
      return (
        success: false,
        message: 'Lesson tidak ditemukan.',
        xpAwarded: 0,
        leveledUp: false,
      );
    }

    if (!lesson.hasExecutedQuery) {
      return (
        success: false,
        message:
            'REQUIREMENTS_NOT_MET: Jalankan minimal 1 query latihan di editor sebelum menyelesaikan lesson.',
        xpAwarded: 0,
        leveledUp: false,
      );
    }

    if (lesson.quizQuestions.isNotEmpty && !lesson.hasPassedQuiz) {
      return (
        success: false,
        message:
            'REQUIREMENTS_NOT_MET: Selesaikan kuis lesson dengan skor minimal 70% terlebih dahulu.',
        xpAwarded: 0,
        leveledUp: false,
      );
    }

    final wasAlreadyCompleted = lesson.status == 'completed';

    // Update lesson status to completed & unlock next lesson in path
    bool unlockNext = false;
    String? nextLessonId;

    final updatedPaths = state.paths.map((path) {
      final updatedModules = path.modules.map((mod) {
        final updatedLessons = mod.lessons.map((les) {
          if (les.id == lessonId) {
            unlockNext = true;
            return les.copyWith(status: 'completed');
          }
          if (unlockNext && nextLessonId == null) {
            nextLessonId = les.id;
            unlockNext = false;
            if (les.status == 'locked') {
              return les.copyWith(status: 'available');
            }
          }
          return les;
        }).toList();
        return mod.copyWith(lessons: updatedLessons);
      }).toList();
      return path.copyWith(modules: updatedModules);
    }).toList();

    state = state.copyWith(
      paths: updatedPaths,
      lastAccessedLessonId: nextLessonId ?? lessonId,
    );

    int xpGiven = 0;
    bool leveledUp = false;
    if (!wasAlreadyCompleted) {
      xpGiven = lesson.xpReward;
      leveledUp = _awardXp(
        sourceType: 'lesson',
        sourceId: lesson.id,
        amount: xpGiven,
        idempotencyKey: 'lesson_${lesson.id}',
      );
      _incrementMissionProgress('lesson_completed', 1);
      _unlockAchievement('first_lesson');
      _recordAnalyticsEvent('lesson_completed', {
        'lesson_id': lesson.id,
        'xp_awarded': xpGiven,
        'time_spent_seconds': lesson.estimatedMinutes * 60,
      });
    }

    _recordValidLearningActivity();

    return (
      success: true,
      message: wasAlreadyCompleted
          ? 'Lesson selesai diulang! (XP sudah pernah diklaim sebelumnya)'
          : 'Lesson selesai! +$xpGiven XP',
      xpAwarded: xpGiven,
      leveledUp: leveledUp,
    );
  }

  void _updateLesson(
    String lessonId,
    LessonModel Function(LessonModel) updater,
  ) {
    final updatedPaths = state.paths.map((path) {
      final updatedModules = path.modules.map((mod) {
        final updatedLessons = mod.lessons.map((les) {
          if (les.id == lessonId) return updater(les);
          return les;
        }).toList();
        return mod.copyWith(lessons: updatedLessons);
      }).toList();
      return path.copyWith(modules: updatedModules);
    }).toList();
    state = state.copyWith(paths: updatedPaths);
  }

  /// AC-09: Membuka Hint berikutnya pada SQL Challenge (biaya 10% XP dasar per hint)
  String? unlockNextHint(String challengeId) {
    final idx = state.challenges.indexWhere((c) => c.id == challengeId);
    if (idx == -1) return null;
    final chal = state.challenges[idx];
    if (chal.hintsOpened >= chal.hints.length) return null;

    final nextOpened = chal.hintsOpened + 1;
    final updated = List<SqlChallengeModel>.from(state.challenges);
    updated[idx] = chal.copyWith(hintsOpened: nextOpened);
    state = state.copyWith(challenges: updated);
    return chal.hints[nextOpened - 1];
  }

  /// AC-06, AC-07, AC-08: Submit jawaban SQL Challenge
  ({
    SandboxExecutionResult execution,
    int xpAwarded,
    int attemptsRemaining,
    bool leveledUp,
  }) submitChallengeQuery({
    required String challengeId,
    required String query,
  }) {
    final idx = state.challenges.indexWhere((c) => c.id == challengeId);
    final chal = state.challenges[idx];

    if (chal.isAttemptsExhausted) {
      return (
        execution: const SandboxExecutionResult(
          resultStatus: 'attempts_exhausted',
          message: 'Percobaan habis. Lihat penjelasan jawaban.',
        ),
        xpAwarded: 0,
        attemptsRemaining: 0,
        leveledUp: false,
      );
    }

    final result = SqlSandboxEngine.execute(
      rawQuery: query,
      tables: chal.tables,
      referenceQuery: chal.referenceQuery,
      expectedColumns: chal.expectedColumns,
      expectedRows: chal.expectedRows,
      ordered: chal.ordered,
      strictColumns: chal.strictColumns,
      allowDml: chal.allowDml,
      isSubmit: true,
    );

    _unlockAchievement('first_sql_query');

    // Bagian 36: syntax_error dan blocked TIDAK mengurangi jatah percobaan!
    if (result.resultStatus == 'syntax_error' ||
        result.resultStatus == 'blocked') {
      final rem = chal.maxAttempts == null
          ? 99
          : (chal.maxAttempts! - chal.attemptsUsed).clamp(0, 99);
      return (
        execution: result,
        xpAwarded: 0,
        attemptsRemaining: rem,
        leveledUp: false,
      );
    }

    final nextAttempts = chal.attemptsUsed + 1;
    final alreadySolved = chal.isCompleted;

    if (result.resultStatus == 'correct') {
      final xp = SqlSandboxEngine.calculateChallengeXp(
        baseXp: chal.xpReward,
        attemptNumber: nextAttempts,
        hintsUsed: chal.hintsOpened,
        alreadySolvedBefore: alreadySolved,
      );

      final updatedList = List<SqlChallengeModel>.from(state.challenges);
      updatedList[idx] = chal.copyWith(
        isCompleted: true,
        attemptsUsed: nextAttempts,
      );
      state = state.copyWith(challenges: updatedList);

      bool leveledUp = false;
      if (xp > 0) {
        leveledUp = _awardXp(
          sourceType: 'challenge',
          sourceId: chal.id,
          amount: xp,
          idempotencyKey: 'challenge_${chal.id}',
        );
        _incrementMissionProgress('challenges_completed', 1);
      }

      _recordValidLearningActivity();
      _unlockAchievement('first_game');
      if ((chal.difficulty == 'Hard' || chal.difficulty == 'Expert') &&
          nextAttempts == 1 &&
          chal.hintsOpened == 0) {
        _unlockAchievement('perfect_score');
      }

      _recordAnalyticsEvent('sql_challenge_completed', {
        'challenge_id': chal.id,
        'attempts': nextAttempts,
        'hints_used': chal.hintsOpened,
        'xp_awarded': xp,
      });

      final rem = chal.maxAttempts == null
          ? 99
          : (chal.maxAttempts! - nextAttempts).clamp(0, 99);
      return (
        execution: result,
        xpAwarded: xp,
        attemptsRemaining: rem,
        leveledUp: leveledUp,
      );
    } else {
      // wrong_result or timeout reduces attempts
      final updatedList = List<SqlChallengeModel>.from(state.challenges);
      updatedList[idx] = chal.copyWith(attemptsUsed: nextAttempts);
      state = state.copyWith(challenges: updatedList);
      _recordValidLearningActivity();

      final rem = chal.maxAttempts == null
          ? (5 - nextAttempts).clamp(0, 5)
          : (chal.maxAttempts! - nextAttempts).clamp(0, 99);

      if (chal.maxAttempts != null && nextAttempts >= chal.maxAttempts!) {
        return (
          execution: SandboxExecutionResult(
            resultStatus: 'attempts_exhausted',
            message: 'Percobaan habis. Lihat penjelasan jawaban.',
            columns: result.columns,
            rows: result.rows,
            rowCount: result.rowCount,
          ),
          xpAwarded: 0,
          attemptsRemaining: 0,
          leveledUp: false,
        );
      }

      return (
        execution: result,
        xpAwarded: 0,
        attemptsRemaining: rem,
        leveledUp: false,
      );
    }
  }

  void resetChallengeAttempts(String challengeId) {
    final idx = state.challenges.indexWhere((c) => c.id == challengeId);
    if (idx == -1) return;
    final updated = List<SqlChallengeModel>.from(state.challenges);
    updated[idx] = updated[idx].copyWith(attemptsUsed: 0);
    state = state.copyWith(challenges: updated);
  }

  /// Bagian 20: Klaim/Complete Misi Harian
  int claimDailyMission(String missionId) {
    final idx = state.dailyMissions.indexWhere((m) => m.id == missionId);
    if (idx == -1) return 0;
    final m = state.dailyMissions[idx];

    final updated = List<DailyMissionModel>.from(state.dailyMissions);
    updated[idx] = m.copyWith(
      progress: m.target,
      status: 'completed',
      xpAwarded: true,
    );
    state = state.copyWith(dailyMissions: updated);

    _awardXp(
      sourceType: 'mission',
      sourceId: m.id,
      amount: m.xpReward,
      idempotencyKey: 'mission_${m.id}_${DateTime.now().day}',
    );

    // Bonus 30 XP bila ketiga misi selesai pada hari yang sama (Bagian 20)
    if (state.dailyMissions.every((mis) => mis.status == 'completed')) {
      _awardXp(
        sourceType: 'mission',
        sourceId: 'all_daily_bonus',
        amount: 30,
        idempotencyKey: 'daily_bonus_${DateTime.now().day}',
      );
      return m.xpReward + 30;
    }
    return m.xpReward;
  }

  /// Bagian 26 & FR-PRF-01: Update profil
  String? updateProfile({
    required String fullName,
    required String username,
    String? avatarUrl,
  }) {
    final cleanName = fullName.trim();
    final cleanUser = username.trim().toLowerCase();
    if (cleanName.length < 2 || cleanName.length > 50) {
      return 'Nama harus terdiri dari 2–50 karakter.';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(cleanUser)) {
      return 'Username harus 3–20 karakter (huruf, angka, atau _).';
    }
    if (cleanUser != state.user.username &&
        _takenUsernames.contains(cleanUser)) {
      return 'Username sudah digunakan pengguna lain.';
    }

    _takenUsernames.add(cleanUser);
    state = state.copyWith(
      user: state.user.copyWith(
        fullName: cleanName,
        username: cleanUser,
        avatarUrl: avatarUrl,
      ),
    );
    return null;
  }

  void updatePreferences({
    String? themeMode,
    String? language,
    bool? hideFromLeaderboard,
    String? reminderTime,
    bool? soundEnabled,
  }) {
    state = state.copyWith(
      user: state.user.copyWith(
        themeMode: themeMode,
        language: language,
        hideFromLeaderboard: hideFromLeaderboard,
        reminderTime: reminderTime,
      ),
      soundEnabled: soundEnabled,
    );
  }

  void markNotificationRead(String id) {
    final updated = state.notifications.map((n) {
      if (n.id == id) return n.copyWith(isRead: true);
      return n;
    }).toList();
    state = state.copyWith(notifications: updated);
  }

  void markAllNotificationsRead() {
    final updated =
        state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updated);
  }

  void setSimulatedState(ScreenSimulatedState simState) {
    state = state.copyWith(simulatedState: simState);
  }

  Future<void> logout() async {
    await ref.read(secureTokenStorageProvider).clearTokens();
    state = state.copyWith(isAuthenticated: false);
  }

  /// AC-14: Hapus akun (dinonaktifkan langsung, sesi dicabut, dikeluarkan dari leaderboard)
  Future<bool> deleteAccount(String confirmPassword) async {
    if (confirmPassword.trim().isEmpty) return false;
    await ref.read(secureTokenStorageProvider).clearTokens();
    state = state.copyWith(
      isAuthenticated: false,
      user: state.user.copyWith(
        status: 'deleted',
        hideFromLeaderboard: true,
      ),
    );
    return true;
  }
}

