class AppConstants {
  AppConstants._();

  static const String appName = 'SQLQuest';
  static const String appVersion = '1.0.0+1';
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.sqlquest.dev/api/v1',
  );

  static const int maxDailyChallengeQuizXp = 1000;
  static const int maxQueryLength = 5000;

  /// Formula level (Section 21):
  /// XP_kumulatif(L) = 50 * L * (L - 1)
  /// XP needed from L to L+1 = 100 * L. Level 1 starts at 0 XP.
  static int cumulativeXpForLevel(int level) {
    if (level <= 1) return 0;
    return 50 * level * (level - 1);
  }

  static int xpForNextLevel(int currentLevel) {
    return cumulativeXpForLevel(currentLevel + 1);
  }

  static int calculateLevelFromXp(int totalXp) {
    int level = 1;
    while (cumulativeXpForLevel(level + 1) <= totalXp) {
      level++;
    }
    return level;
  }

  static String levelTitle(int level) {
    switch (level) {
      case 1:
        return 'SQL Beginner';
      case 2:
        return 'Query Learner';
      case 3:
        return 'Query Explorer';
      case 4:
        return 'SQL Practitioner';
      case 5:
        return 'SQL Specialist';
      case 6:
        return 'Database Analyst';
      case 7:
        return 'Schema Architect';
      case 8:
        return 'Query Optimizer';
      case 9:
        return 'Data Engineer';
      default:
        return 'SQL Master';
    }
  }
}

class AppStrings {
  final String languageCode;
  const AppStrings(this.languageCode);

  bool get isId => languageCode == 'id';

  String get homeTab => isId ? 'Beranda' : 'Home';
  String get learnTab => isId ? 'Belajar' : 'Learn';
  String get gameTab => isId ? 'Game' : 'Game';
  String get profileTab => isId ? 'Profil' : 'Profile';

  String get homeTagline => isId
      ? 'Kuasai PostgreSQL selangkah demi selangkah'
      : 'Master PostgreSQL step by step';

  String greeting(String name) => isId ? 'Hai, $name!' : 'Hi, $name!';
  String daysStreak(int days) => isId ? '$days Hari' : '$days Days';
  String consecutiveDays(int days) =>
      isId ? '$days hari berturut-turut' : '$days days in a row';
  String xpToNextLevel(int xp, int nextLevel) =>
      isId ? '$xp XP lagi ke Level $nextLevel' : '$xp XP to Level $nextLevel';

  String get learningProgress =>
      isId ? 'Progress Belajar' : 'Learning Progress';
  String get coursesStat => isId ? 'Kursus' : 'Courses';
  String get badgesStat => isId ? 'Badge' : 'Badges';
  String get dailyChallenge => isId ? 'Tantangan Harian' : 'Daily Missions';
  String get thisWeek => isId ? 'Minggu Ini' : 'This Week';
  String get quickStats => isId ? 'Statistik Cepat' : 'Quick Stats';
  String get accuracy30d => isId ? 'Akurasi (30 hr)' : 'Accuracy (30d)';
  String get missionsDone30d => isId ? 'Misi Selesai' : 'Missions Done';
  String get continueLearning =>
      isId ? 'Lanjutkan Belajar' : 'Continue Learning';
  String get seeAll => isId ? 'Lihat semua' : 'See all';
  String get currentRanking => isId ? 'Peringkat' : 'Leaderboard';
  String get recommendedChallenge =>
      isId ? 'Challenge Rekomendasi' : 'Recommended Challenge';

  String get searchMaterialHint => isId
      ? 'Cari materi atau topik SQL...'
      : 'Search SQL topics or lessons...';
  String get filterAll => isId ? 'Semua' : 'All';
  String get filterInProgress => isId ? 'Sedang berjalan' : 'In Progress';
  String get filterCompleted => isId ? 'Selesai' : 'Completed';
  String get emptyMaterials =>
      isId ? 'Belum ada materi' : 'No learning materials yet';
  String durationMinutes(int min) => isId ? '$min menit' : '$min mins';

  String get offlineBanner => isId
      ? 'Tidak ada koneksi internet. Menampilkan konten cache.'
      : 'No internet connection. Showing cached content.';
  String get genericError => isId
      ? 'Terjadi kesalahan. Coba lagi sebentar lagi.'
      : 'An error occurred. Please try again.';
  String get retry => isId ? 'Coba lagi' : 'Retry';
}

