import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/models/app_state_provider.dart';
import '../../../shared/widgets/sqlquest_widgets.dart';

/// Bagian 14 (Layar Profil) & Bagian 26:
/// - Avatar default ilustrasi/inisial, nama, @username (tanpa titik online, tanpa badge Pro, tanpa Liga Ruby, tanpa Sertifikat sesuai Bagian 18 #4, #5, #6)
/// - Chip streak "{n} Hari" + progress level & teks "{x} XP lagi ke Level {n+1}"
/// - Grid statistik: Modul Selesai, Misi Selesai, Akurasi Rata-rata, Challenge Selesai
/// - Pencapaian & Badge carousel horizontal + "Lihat Semua"
/// - Menu: Peringkat (Leaderboard), Pengingat Harian & Notifikasi, Akun & Keamanan, Pusat Bantuan, Keluar dari Akun, versi aplikasi
/// - Aksi header: Bagikan profil & Pengaturan
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showShareProfileSheet(BuildContext context, UserProfileModel user, int badgesCount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kartu Profil Publik'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppCard(
              gradient: DesignTokens.heroCardGradient,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      user.fullName.isNotEmpty
                          ? user.fullName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '@${user.username}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      StatusPill(
                        label: 'Lv.${user.level} ${user.levelTitle}',
                        color: Colors.white,
                      ),
                      StatusPill(
                        label: '$badgesCount Badge',
                        color: Colors.amber,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final user = state.user;
    final strings = state.strings;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            emptyMessage: 'Profil belum tersedia.',
            onRetry: () => ref
                .read(appStateProvider.notifier)
                .setSimulatedState(ScreenSimulatedState.normal),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                // Aksi Header: Judul Profil + Bagikan Profil + Pengaturan
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        strings.profileTab,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Bagikan Profil',
                      onPressed: () => _showShareProfileSheet(
                        context,
                        user,
                        state.unlockedBadgesCount,
                      ),
                      icon: const Icon(Icons.share_outlined),
                    ),
                    IconButton(
                      tooltip: 'Pengaturan',
                      onPressed: () => context.push('/settings'),
                      icon: const Icon(Icons.settings_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Kartu Identitas, Chip Streak & Level
                AppCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: DesignTokens.heroCardGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              user.fullName.isNotEmpty
                                  ? user.fullName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.fullName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '@${user.username} · ${user.email}',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    StreakChip(streakDays: user.currentStreak),
                                    StatusPill(
                                      label:
                                          'Lv.${user.level} · ${user.levelTitle}',
                                      color: DesignTokens.primaryLight,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      XpProgressBar(
                        progress: user.levelProgress,
                        leftLabel: '${user.totalXp} XP Saat Ini',
                        rightLabel: strings.xpToNextLevel(
                          user.xpRemainingToNextLevel,
                          user.level + 1,
                        ),
                        color: DesignTokens.primaryLight,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Grid Statistik (Modul Selesai, Misi Selesai, Akurasi Rata-rata, Challenge Selesai — Sertifikat disembunyikan di MVP)
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        label: 'Modul Selesai',
                        value: '${state.totalCompletedModules}',
                        icon: Icons.auto_stories_rounded,
                        accentColor: DesignTokens.primaryLight,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatTile(
                        label: 'Misi Selesai',
                        value: '${state.completedDailyMissionsCount}',
                        icon: Icons.flag_rounded,
                        accentColor: DesignTokens.xpRewardLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        label: 'Akurasi Rata-rata',
                        value: '${state.accuracyPercent}%',
                        icon: Icons.verified_rounded,
                        accentColor: DesignTokens.successLight,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatTile(
                        label: 'Longest Streak',
                        value: '${user.longestStreak} Hari',
                        icon: Icons.local_fire_department_rounded,
                        accentColor: const Color(0xFFEA580C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Pencapaian & Badge (Carousel Horizontal + "Lihat Semua")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pencapaian & Badge (${state.unlockedBadgesCount} didapat)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/achievements'),
                      child: const Text('Lihat Semua'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 148,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.achievements.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, idx) {
                      return BadgeTile(
                        achievement: state.achievements[idx],
                        onTap: () => context.push('/achievements'),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),

                // Menu Daftar Pengaturan & Navigasi
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      SettingsListTile(
                        icon: Icons.leaderboard_rounded,
                        title: 'Peringkat (Leaderboard)',
                        subtitle:
                            'Peringkat Global #${user.rankGlobal} · ${user.totalXp} XP',
                        onTap: () => context.push('/leaderboard'),
                      ),
                      const Divider(height: 1),
                      SettingsListTile(
                        icon: Icons.edit_outlined,
                        title: 'Edit Profil',
                        subtitle: 'Ubah nama lengkap, @username, dan avatar',
                        onTap: () => context.push('/profile/edit'),
                      ),
                      const Divider(height: 1),
                      SettingsListTile(
                        icon: Icons.notifications_active_outlined,
                        title: 'Pengingat Harian & Notifikasi',
                        subtitle:
                            'Pengingat pukul ${user.reminderTime} (${user.timezone})',
                        onTap: () => context.push('/notifications'),
                      ),
                      const Divider(height: 1),
                      SettingsListTile(
                        icon: Icons.security_rounded,
                        title: 'Akun, Tema, Bahasa & Keamanan',
                        subtitle:
                            'Ganti password, tema (${user.themeMode}), bahasa (${user.language.toUpperCase()}), privasi, hapus akun',
                        onTap: () => context.push('/settings'),
                      ),
                      const Divider(height: 1),
                      SettingsListTile(
                        icon: Icons.help_outline_rounded,
                        title: 'Pusat Bantuan & FAQ SQL Sandbox',
                        subtitle: 'Panduan dialek PostgreSQL 15+ & aturan XP',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Pusat Bantuan SQLQuest'),
                              content: const Text(
                                '• Seluruh query dijalankan di sandbox PostgreSQL terisolasi (timeout 3 detik, maks 500 baris).\n'
                                '• Formula Level: XP_kumulatif(L) = 50 × L × (L - 1).\n'
                                '• Streak bertambah 1 kali per hari lokal saat ada learning activity valid.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Tutup'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      SettingsListTile(
                        icon: Icons.logout_rounded,
                        iconColor: DesignTokens.errorLight,
                        title: 'Keluar dari Akun',
                        subtitle: 'Mencabut refresh token perangkat ini',
                        onTap: () async {
                          await ref.read(appStateProvider.notifier).logout();
                          if (context.mounted) context.go('/login');
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    '${AppConstants.appName} v${AppConstants.appVersion} · PostgreSQL 15 Sandbox',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
