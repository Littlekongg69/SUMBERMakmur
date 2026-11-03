import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/models/app_state_provider.dart';
import '../../../shared/models/seed_data.dart';
import '../../../shared/widgets/sqlquest_widgets.dart';

/// Bagian 14 (Layar Beranda).
///
/// Urutan konten disusun berdasarkan prioritas pengguna:
///   1. Status saya      -> Header, Kartu Sapaan (level, XP, streak)
///   2. Aksi berikutnya  -> Lanjutkan Belajar (progress path + modul)
///   3. Kebiasaan harian -> Tantangan Harian, Minggu Ini, Statistik Cepat
///   4. Eksplorasi       -> Challenge Rekomendasi, Peringkat
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const double _sectionGap = 20;
  static const double _itemGap = 12;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final user = state.user;
    final strings = state.strings;
    final activePath = state.activePath;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalMods = activePath.modules.length;
    final doneMods = activePath.completedModules;
    final modPercent =
    totalMods == 0 ? 0 : ((doneMods / totalMods) * 100).round();

    final primaryMission = state.dailyMissions.firstWhere(
          (m) => m.status != 'completed',
      orElse: () => state.dailyMissions.first,
    );

    final top3Leaderboard = SeedData.buildLeaderboard(
      currentUser: user,
      periodType: 'global',
    ).take(3).toList();

    final previewModules = activePath.modules.take(3).toList();
    final recommendedChallenge = state.recommendedChallenge;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? DesignTokens.darkPageGradient
              : DesignTokens.lightPageGradient,
        ),
        child: SafeArea(
          child: ScreenStateWrapper(
            state: state.simulatedState,
            emptyMessage: 'Belum ada aktivitas di Beranda.',
            onRetry: () => ref
                .read(appStateProvider.notifier)
                .setSimulatedState(ScreenSimulatedState.normal),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                // 1. Header: judul, tagline, notifikasi, profil
                _HomeHeader(
                  title: strings.homeTab,
                  tagline: strings.homeTagline,
                  initial: user.fullName.isNotEmpty
                      ? user.fullName[0].toUpperCase()
                      : 'U',
                  unreadCount: state.unreadNotificationCount,
                  onNotifications: () => context.push('/notifications'),
                  onProfile: () => context.go('/profile'),
                ),
                const SizedBox(height: 16),

                // FR-AUTH-02: pengingat verifikasi email
                if (!user.emailVerified) ...[
                  _EmailVerifyBanner(
                    onVerify: () => ref
                        .read(appStateProvider.notifier)
                        .verifyEmailNow(),
                  ),
                  const SizedBox(height: _itemGap),
                ],

                // 2. Kartu Sapaan: satu-satunya elemen yang dibuat "menonjol"
                _HeroCard(
                  greeting: strings.greeting(user.fullName.split(' ').first),
                  levelLabel: 'Level ${user.level} · ${user.levelTitle}',
                  streakDays: user.currentStreak,
                  levelProgress: user.levelProgress,
                  xpLeftLabel: 'XP Level ${user.level}',
                  xpRightLabel: '${user.totalXp} / ${user.xpForNextLevel} XP',
                  remainingLabel: strings.xpToNextLevel(
                    user.xpRemainingToNextLevel,
                    user.level + 1,
                  ),
                ),
                const SizedBox(height: _sectionGap),

                // 3 + 7. Lanjutkan Belajar: progress path + modul
                _SectionHeader(
                  title: strings.continueLearning,
                  actionLabel: strings.seeAll,
                  onAction: () => context.go('/learn'),
                ),
                const SizedBox(height: 8),
                _LearningProgressCard(
                  title: strings.learningProgress,
                  pathTitle: activePath.title,
                  summary: '$doneMods dari $totalMods modul selesai',
                  percent: modPercent,
                  progress: totalMods == 0 ? 0 : doneMods / totalMods,
                  coursesLabel: strings.coursesStat,
                  coursesValue: '${state.paths.length} Path',
                  badgesLabel: strings.badgesStat,
                  badgesValue:
                  '${state.unlockedBadgesCount}/${state.achievements.length}',
                ),
                const SizedBox(height: _itemGap),
                ...previewModules.map((mod) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ModuleCard(
                      module: mod,
                      onTap: () {
                        if (mod.status == 'locked') {
                          _showLockedModuleBottomSheet(context, mod);
                        } else {
                          context.push(
                            '/lessons/${mod.activeOrFirstLesson.id}',
                          );
                        }
                      },
                    ),
                  );
                }),
                const SizedBox(height: 10),

                // 4. Tantangan Harian
                MissionBanner(
                  mission: primaryMission,
                  onTap: () => context.push('/missions'),
                ),
                const SizedBox(height: _itemGap),

                // 5. Minggu Ini
                WeekStreakRow(
                  activeDays: user.weekActiveDays,
                  currentStreak: user.currentStreak,
                ),
                const SizedBox(height: _itemGap),

                // 6. Statistik Cepat
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        label: strings.accuracy30d,
                        value: '${state.accuracyPercent}%',
                        icon: Icons.track_changes_rounded,
                        accentColor: DesignTokens.successLight,
                      ),
                    ),
                    const SizedBox(width: _itemGap),
                    Expanded(
                      child: StatTile(
                        label: strings.missionsDone30d,
                        value:
                        '${state.completedDailyMissionsCount}/${state.dailyMissions.length}',
                        icon: Icons.task_alt_rounded,
                        accentColor: DesignTokens.primaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: _sectionGap),

                // 8. Challenge Rekomendasi
                _SectionHeader(title: strings.recommendedChallenge),
                const SizedBox(height: 8),
                _RecommendedChallengeCard(
                  difficulty: recommendedChallenge.difficulty,
                  xpReward: recommendedChallenge.xpReward,
                  title: recommendedChallenge.title,
                  description: recommendedChallenge.description,
                  onStart: () => context
                      .push('/game/challenges/${recommendedChallenge.id}'),
                ),
                const SizedBox(height: _sectionGap),

                // 9. Peringkat
                _SectionHeader(
                  title: strings.currentRanking,
                  actionLabel: 'Buka Leaderboard',
                  onAction: () => context.push('/leaderboard'),
                ),
                const SizedBox(height: 8),
                _RankingCard(
                  myRank: user.rankGlobal,
                  myXp: user.totalXp,
                  entries: top3Leaderboard,
                  onTap: () => context.push('/leaderboard'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLockedModuleBottomSheet(BuildContext context, ModuleModel mod) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.lock_rounded,
                  color: DesignTokens.xpRewardLight,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${mod.worldLabel}: ${mod.title} terkunci',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Syarat pembukaan: selesaikan seluruh lesson wajib pada modul prasyarat "${mod.prerequisiteModuleTitle ?? 'modul sebelumnya'}" terlebih dahulu.',
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Mengerti'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Color _mutedText(BuildContext context) =>
    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65);

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _HomeHeader extends StatelessWidget {
  final String title;
  final String tagline;
  final String initial;
  final int unreadCount;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  const _HomeHeader({
    required this.title,
    required this.tagline,
    required this.initial,
    required this.unreadCount,
    required this.onNotifications,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tagline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: _mutedText(context)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Badge(
          isLabelVisible: unreadCount > 0,
          backgroundColor: DesignTokens.errorLight,
          label: Text(unreadCount > 9 ? '9+' : '$unreadCount'),
          child: IconButton.filledTonal(
            tooltip: 'Notifikasi',
            onPressed: onNotifications,
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ),
        const SizedBox(width: 10),
        Semantics(
          button: true,
          label: 'Buka profil',
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onProfile,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: DesignTokens.primaryLight,
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Banner verifikasi email
// ---------------------------------------------------------------------------

class _EmailVerifyBanner extends StatelessWidget {
  final VoidCallback onVerify;
  const _EmailVerifyBanner({required this.onVerify});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderColor: DesignTokens.xpRewardLight,
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      child: Row(
        children: [
          const Icon(
            Icons.mark_email_unread_outlined,
            color: DesignTokens.xpRewardLight,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Verifikasi email agar namamu tampil di Leaderboard.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
          TextButton(onPressed: onVerify, child: const Text('Verifikasi')),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Kartu sapaan
// ---------------------------------------------------------------------------

class _HeroCard extends StatelessWidget {
  final String greeting;
  final String levelLabel;
  final int streakDays;
  final double levelProgress;
  final String xpLeftLabel;
  final String xpRightLabel;
  final String remainingLabel;

  const _HeroCard({
    required this.greeting,
    required this.levelLabel,
    required this.streakDays,
    required this.levelProgress,
    required this.xpLeftLabel,
    required this.xpRightLabel,
    required this.remainingLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: DesignTokens.heroCardGradient,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        levelLabel,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              StreakChip(streakDays: streakDays, inverted: true),
            ],
          ),
          const SizedBox(height: 22),
          XpProgressBar(
            progress: levelProgress,
            leftLabel: xpLeftLabel,
            rightLabel: xpRightLabel,
            color: DesignTokens.xpRewardDark,
            trackColor: Colors.white.withValues(alpha: 0.22),
          ),
          const SizedBox(height: 10),
          Text(
            remainingLabel,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Judul section
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress belajar (ringkas)
// ---------------------------------------------------------------------------

class _LearningProgressCard extends StatelessWidget {
  final String title;
  final String pathTitle;
  final String summary;
  final int percent;
  final double progress;
  final String coursesLabel;
  final String coursesValue;
  final String badgesLabel;
  final String badgesValue;

  const _LearningProgressCard({
    required this.title,
    required this.pathTitle,
    required this.summary,
    required this.percent,
    required this.progress,
    required this.coursesLabel,
    required this.coursesValue,
    required this.badgesLabel,
    required this.badgesValue,
  });

  @override
  Widget build(BuildContext context) {
    final divider = Theme.of(context).dividerColor.withValues(alpha: 0.5);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pathTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$title · $summary',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: _mutedText(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.primaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          XpProgressBar(progress: progress, color: DesignTokens.primaryLight),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _InlineStat(
                  icon: Icons.school_rounded,
                  color: DesignTokens.primaryLight,
                  value: coursesValue,
                  label: coursesLabel,
                ),
              ),
              Container(width: 1, height: 32, color: divider),
              const SizedBox(width: 14),
              Expanded(
                child: _InlineStat(
                  icon: Icons.emoji_events_rounded,
                  color: DesignTokens.xpRewardLight,
                  value: badgesValue,
                  label: badgesLabel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InlineStat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _InlineStat({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.5, color: _mutedText(context)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Challenge rekomendasi
// ---------------------------------------------------------------------------

class _RecommendedChallengeCard extends StatelessWidget {
  final String difficulty;
  final int xpReward;
  final String title;
  final String description;
  final VoidCallback onStart;

  const _RecommendedChallengeCard({
    required this.difficulty,
    required this.xpReward,
    required this.title,
    required this.description,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onStart,
      borderColor: DesignTokens.primaryLight.withValues(alpha: 0.35),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: DesignTokens.primaryLight.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.extension_rounded,
                  color: DesignTokens.primaryLight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    StatusPill(
                      label: difficulty,
                      color: DesignTokens.primaryLight,
                    ),
                    StatusPill(
                      label: '+$xpReward XP',
                      color: DesignTokens.xpRewardLight,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              color: _mutedText(context),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onStart,
              child: const Text('Mulai challenge'),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Peringkat
// ---------------------------------------------------------------------------

class _RankingCard extends StatelessWidget {
  final int myRank;
  final int myXp;
  final List<LeaderboardEntryModel> entries;
  final VoidCallback onTap;

  const _RankingCard({
    required this.myRank,
    required this.myXp,
    required this.entries,
    required this.onTap,
  });

  static const _gold = Color(0xFFD97706);
  static const _silver = Color(0xFF94A3B8);
  static const _bronze = Color(0xFFB45309);

  Color _medalColor(int rank) {
    switch (rank) {
      case 1:
        return _gold;
      case 2:
        return _silver;
      case 3:
        return _bronze;
      default:
        return DesignTokens.primaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Posisi kamu',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: _mutedText(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '#$myRank',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: DesignTokens.primaryLight,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill(
                label: '$myXp XP',
                color: DesignTokens.xpRewardLight,
              ),
            ],
          ),
          const Divider(height: 24),
          ...entries.map((entry) {
            final color = _medalColor(entry.rank);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${entry.rank}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '@${entry.username}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    'Lv.${entry.level} · ${entry.xp} XP',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: _mutedText(context),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}