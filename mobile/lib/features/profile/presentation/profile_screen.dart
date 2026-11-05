import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/models/app_state_provider.dart';
import '../../../shared/widgets/sqlquest_widgets.dart';

/// Bagian 14 (Layar Profil) & Bagian 26:
/// - Avatar inisial, nama, @username (tanpa titik online, badge Pro, Liga Ruby, Sertifikat — Bagian 18 #4, #5, #6)
/// - Chip streak + level & teks "{x} XP lagi ke Level {n+1}"
/// - Grid statistik: Modul Selesai, Misi Selesai, Akurasi Rata-rata, Streak Terpanjang
/// - Pencapaian & Badge carousel horizontal + "Lihat Semua"
/// - Menu: Peringkat, Edit Profil, Pengingat, Akun & Keamanan, Bantuan, Keluar
/// - Aksi header: Bagikan profil & Pengaturan
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final user = state.user;
    final strings = state.strings;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Badge terbuka ditampilkan lebih dulu agar carousel terasa "hidup".
    // Dipisah per kelompok (bukan sort) agar urutan asli tetap terjaga.
    final sortedBadges = [
      ...state.achievements.where((a) => a.isUnlocked),
      ...state.achievements.where((a) => !a.isUnlocked),
    ];

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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                _HeaderBar(
                  title: strings.profileTab,
                  onShare: () => _showShareProfileDialog(
                    context,
                    user,
                    state.unlockedBadgesCount,
                  ),
                  onSettings: () => context.push('/settings'),
                ),
                const SizedBox(height: 12),

                // Kartu identitas + level
                _IdentityCard(
                  user: user,
                  xpToNextLabel: strings.xpToNextLevel(
                    user.xpRemainingToNextLevel,
                    user.level + 1,
                  ),
                  onEdit: () => context.push('/profile/edit'),
                ),
                const SizedBox(height: 14),

                // Statistik
                const _SectionTitle('Statistik Belajar'),
                const SizedBox(height: 8),
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
                        label: 'Streak Terpanjang',
                        value: '${user.longestStreak} Hari',
                        icon: Icons.local_fire_department_rounded,
                        accentColor: const Color(0xFFEA580C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Pencapaian
                Row(
                  children: [
                    Expanded(
                      child: _SectionTitle(
                        'Pencapaian & Badge · ${state.unlockedBadgesCount}/${state.achievements.length}',
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/achievements'),
                      child: const Text('Lihat Semua'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (sortedBadges.isEmpty)
                  const AppCard(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: Text(
                          'Belum ada badge. Selesaikan lesson pertamamu!',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 148,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: sortedBadges.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, idx) => BadgeTile(
                        achievement: sortedBadges[idx],
                        onTap: () => context.push('/achievements'),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),

                // Menu: Aktivitas
                const _SectionTitle('Aktivitas'),
                const SizedBox(height: 8),
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
                        icon: Icons.notifications_active_outlined,
                        title: 'Pengingat Harian & Notifikasi',
                        subtitle:
                            'Pengingat pukul ${user.reminderTime} (${user.timezone})',
                        onTap: () => context.push('/notifications'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Menu: Akun
                const _SectionTitle('Akun'),
                const SizedBox(height: 8),
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      SettingsListTile(
                        icon: Icons.edit_outlined,
                        title: 'Edit Profil',
                        subtitle: 'Ubah nama lengkap dan @username',
                        onTap: () => context.push('/profile/edit'),
                      ),
                      const Divider(height: 1),
                      SettingsListTile(
                        icon: Icons.security_rounded,
                        title: 'Tema, Bahasa & Keamanan',
                        subtitle:
                            'Tema ${_themeLabel(user.themeMode)} · ${user.language.toUpperCase()} · privasi & hapus akun',
                        onTap: () => context.push('/settings'),
                      ),
                      const Divider(height: 1),
                      SettingsListTile(
                        icon: Icons.help_outline_rounded,
                        title: 'Pusat Bantuan & FAQ SQL Sandbox',
                        subtitle: 'Panduan dialek PostgreSQL 15+ & aturan XP',
                        onTap: () => _showHelpDialog(context),
                      ),
                      const Divider(height: 1),
                      SettingsListTile(
                        icon: Icons.logout_rounded,
                        iconColor: DesignTokens.errorLight,
                        title: 'Keluar dari Akun',
                        subtitle: 'Mencabut refresh token perangkat ini',
                        onTap: () => _confirmLogout(context, ref),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
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

  static String _themeLabel(String mode) {
    switch (mode) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      default:
        return 'Sistem';
    }
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text(
          'Sesi di perangkat ini akan dicabut. Kamu perlu login lagi untuk melanjutkan belajar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.errorLight,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(appStateProvider.notifier).logout();
    if (context.mounted) context.go('/login');
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pusat Bantuan SQLQuest'),
        content: const Text(
          '• Seluruh query dijalankan di sandbox PostgreSQL terisolasi (timeout 3 detik, maks 500 baris).\n\n'
          '• Formula Level: XP_kumulatif(L) = 50 × L × (L - 1).\n\n'
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
  }

  void _showShareProfileDialog(
    BuildContext context,
    UserProfileModel user,
    int badgesCount,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        title: const Text('Kartu Profil Publik'),
        content: SizedBox(
          width: double.maxFinite,
          child: AppCard(
            gradient: DesignTokens.heroCardGradient,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _InitialAvatar(
                  name: user.fullName,
                  size: 64,
                  radius: 32,
                  onGradient: true,
                ),
                const SizedBox(height: 10),
                Text(
                  user.fullName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
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
}

class _HeaderBar extends StatelessWidget {
  final String title;
  final VoidCallback onShare;
  final VoidCallback onSettings;

  const _HeaderBar({
    required this.title,
    required this.onShare,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
        ),
        IconButton(
          tooltip: 'Bagikan Profil',
          onPressed: onShare,
          icon: const Icon(Icons.share_outlined),
        ),
        IconButton(
          tooltip: 'Pengaturan',
          onPressed: onSettings,
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }
}

class _IdentityCard extends StatelessWidget {
  final UserProfileModel user;
  final String xpToNextLabel;
  final VoidCallback onEdit;

  const _IdentityCard({
    required this.user,
    required this.xpToNextLabel,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InitialAvatar(name: user.fullName, size: 68, radius: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${user.username}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? DesignTokens.primaryDark
                            : DesignTokens.primaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Edit Profil',
                visualDensity: VisualDensity.compact,
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                StreakChip(streakDays: user.currentStreak),
                StatusPill(
                  label: 'Lv.${user.level} · ${user.levelTitle}',
                  color: DesignTokens.primaryLight,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          XpProgressBar(
            progress: user.levelProgress,
            leftLabel: '${user.totalXp} XP Saat Ini',
            rightLabel: xpToNextLabel,
            color: DesignTokens.primaryLight,
          ),
        ],
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  final String name;
  final double size;
  final double radius;
  final bool onGradient;

  const _InitialAvatar({
    required this.name,
    required this.size,
    required this.radius,
    this.onGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U';
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: onGradient ? null : DesignTokens.heroCardGradient,
        color: onGradient ? Colors.white.withValues(alpha: 0.2) : null,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
    );
  }
}
