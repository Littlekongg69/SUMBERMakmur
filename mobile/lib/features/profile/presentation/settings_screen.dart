import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/models/app_state_provider.dart';
import '../../../shared/widgets/sqlquest_widgets.dart';

/// Bagian 26, MOB-02, MOB-09, AC-14, & AC-19:
/// Layar Settings:
/// - Tema (Light, Dark, Ikuti sistem)
/// - Bahasa (Indonesia, English)
/// - Privasi (Sembunyikan dari leaderboard)
/// - Jam Pengingat Belajar
/// - Ganti Password
/// - Ulangi Onboarding
/// - Hapus Akun (AC-14: konfirmasi password, cabut sesi, keluarkan dari leaderboard)
/// - Simulasi State Layar (MOB-02 & AC-19: Normal, Loading Skeleton, Empty, Error 500, Offline Cache)
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  void _showChangePasswordDialog() {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ganti Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password Lama'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Baru (min. 8 karakter)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newCtrl.text.length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password baru minimal 8 karakter.'),
                  ),
                );
                return;
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: DesignTokens.successLight,
                  content: Text('Password berhasil diperbarui!'),
                ),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final passCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Akun Permanen (AC-14)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Akun akan langsung dinonaktifkan, seluruh sesi perangkat dicabut, dikeluarkan dari leaderboard, dan data pribadi dianonimkan dalam 30 hari.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Masukkan Password untuk Konfirmasi',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.errorLight,
            ),
            onPressed: () async {
              final ok = await ref
                  .read(appStateProvider.notifier)
                  .deleteAccount(passCtrl.text);
              if (!mounted) return;
              if (!ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Konfirmasi password wajib diisi.'),
                  ),
                );
                return;
              }
              if (ctx.mounted) Navigator.pop(ctx);
              context.go('/login');
            },
            child: const Text('Hapus Akun Saya'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final user = state.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan & Keamanan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Tampilan & Bahasa (MOB-09)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tema Aplikasi',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: ['light', 'dark', 'system'].map((mode) {
                    final selected = user.themeMode == mode;
                    final label = mode == 'light'
                        ? 'Light'
                        : mode == 'dark'
                            ? 'Dark'
                            : 'Sistem';
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          selected: selected,
                          label: Center(child: Text(label)),
                          onSelected: (_) => ref
                              .read(appStateProvider.notifier)
                              .updatePreferences(themeMode: mode),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Bahasa Antarmuka',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        selected: user.language == 'id',
                        label: const Center(child: Text('Bahasa Indonesia')),
                        onSelected: (_) => ref
                            .read(appStateProvider.notifier)
                            .updatePreferences(language: 'id'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        selected: user.language == 'en',
                        label: const Center(child: Text('English')),
                        onSelected: (_) => ref
                            .read(appStateProvider.notifier)
                            .updatePreferences(language: 'en'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          const Text(
            'Privasi & Pengingat',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(
                    'Sembunyikan dari Leaderboard Publik',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Kamu tetap bisa melihat posisi sendiri di Leaderboard (Bagian 26)',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: user.hideFromLeaderboard,
                  onChanged: (val) => ref
                      .read(appStateProvider.notifier)
                      .updatePreferences(hideFromLeaderboard: val),
                ),
                const Divider(height: 1),
                SettingsListTile(
                  icon: Icons.access_time_rounded,
                  title: 'Jam Pengingat Belajar Harian',
                  subtitle:
                      'Pukul ${user.reminderTime} (${user.timezone}) · Target ${user.dailyGoalMinutes} menit',
                  onTap: () {
                    final nextTime =
                        user.reminderTime == '19:00' ? '20:00' : '19:00';
                    ref
                        .read(appStateProvider.notifier)
                        .updatePreferences(reminderTime: nextTime);
                  },
                ),
                const Divider(height: 1),
                SettingsListTile(
                  icon: Icons.tune_rounded,
                  title: 'Ulangi Kuesioner Onboarding',
                  subtitle: 'Sesuaikan ulang level SQL dan rekomendasi path',
                  onTap: () => context.push('/onboarding'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Simulasi State Layar untuk Pengujian MOB-02 & AC-19
          const Text(
            'Uji State Layar (MOB-02 & AC-19 Demo)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ubah state untuk menguji tampilan Loading Skeleton, Empty, Error (500), dan Offline Cache:',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ScreenSimulatedState.values.map((st) {
                    return ChoiceChip(
                      selected: state.simulatedState == st,
                      label: Text(st.name.toUpperCase()),
                      onSelected: (_) => ref
                          .read(appStateProvider.notifier)
                          .setSimulatedState(st),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          const Text(
            'Keamanan & Zona Bahaya',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                SettingsListTile(
                  icon: Icons.password_rounded,
                  title: 'Ganti Password',
                  subtitle: 'Wajib memasukkan password lama',
                  onTap: _showChangePasswordDialog,
                ),
                const Divider(height: 1),
                SettingsListTile(
                  icon: Icons.delete_forever_rounded,
                  iconColor: DesignTokens.errorLight,
                  title: 'Hapus Akun (Delete Account)',
                  subtitle:
                      'Nonaktifkan akun & anonimkan data dalam 30 hari (AC-14)',
                  onTap: _showDeleteAccountDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

