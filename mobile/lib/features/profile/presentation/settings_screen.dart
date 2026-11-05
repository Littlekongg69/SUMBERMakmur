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
  Future<void> _pickReminderTime() async {
    final user = ref.read(appStateProvider).user;
    final parts = user.reminderTime.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.first) ?? 19,
      minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: 'Pilih jam pengingat belajar',
    );
    if (picked == null || !mounted) return;

    final hh = picked.hour.toString().padLeft(2, '0');
    final mm = picked.minute.toString().padLeft(2, '0');
    ref
        .read(appStateProvider.notifier)
        .updatePreferences(reminderTime: '$hh:$mm');
  }

  Future<void> _showChangePasswordDialog() async {
    final success = await showDialog<bool>(
      context: context,
      builder: (_) => const _ChangePasswordDialog(),
    );
    if (success == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: DesignTokens.successLight,
          content: Text('Password berhasil diperbarui!'),
        ),
      );
    }
  }

  Future<void> _showDeleteAccountDialog() async {
    // GoRouter diambil sebelum dialog dibuka agar aman dipakai setelah async.
    final router = GoRouter.of(context);
    final deleted = await showDialog<bool>(
      context: context,
      builder: (_) => const _DeleteAccountDialog(),
    );
    if (deleted == true) router.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final user = state.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan & Keamanan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // ── Tampilan & Bahasa ──
          const _SectionTitle('Tampilan & Bahasa'),
          const SizedBox(height: 8),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FieldLabel('Tema Aplikasi'),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: 'light', label: Text('Light')),
                      ButtonSegment(value: 'dark', label: Text('Dark')),
                      ButtonSegment(value: 'system', label: Text('Sistem')),
                    ],
                    selected: {user.themeMode},
                    onSelectionChanged: (sel) => ref
                        .read(appStateProvider.notifier)
                        .updatePreferences(themeMode: sel.first),
                  ),
                ),
                const SizedBox(height: 16),
                const _FieldLabel('Bahasa Antarmuka'),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: 'id', label: Text('Indonesia')),
                      ButtonSegment(value: 'en', label: Text('English')),
                    ],
                    selected: {user.language},
                    onSelectionChanged: (sel) => ref
                        .read(appStateProvider.notifier)
                        .updatePreferences(language: sel.first),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Privasi & Pengingat ──
          const _SectionTitle('Privasi & Pengingat'),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  title: const Text(
                    'Sembunyikan dari Leaderboard Publik',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Kamu tetap bisa melihat posisimu sendiri di Leaderboard',
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
                  onTap: _pickReminderTime,
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
          const SizedBox(height: 20),

          // ── Keamanan ──
          const _SectionTitle('Keamanan'),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: SettingsListTile(
              icon: Icons.password_rounded,
              title: 'Ganti Password',
              subtitle: 'Wajib memasukkan password lama',
              onTap: _showChangePasswordDialog,
            ),
          ),
          const SizedBox(height: 20),

          // ── Simulasi State Layar (MOB-02 & AC-19) ──
          const _SectionTitle('Uji State Layar (Demo)'),
          const SizedBox(height: 8),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ubah state untuk menguji tampilan Loading Skeleton, Empty, Error (500), dan Offline Cache.',
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
          const SizedBox(height: 20),

          // ── Zona Bahaya (AC-14) ──
          const _SectionTitle('Zona Bahaya', color: DesignTokens.errorLight),
          const SizedBox(height: 8),
          AppCard(
            borderColor: DesignTokens.errorLight.withValues(alpha: 0.5),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: SettingsListTile(
              icon: Icons.delete_forever_rounded,
              iconColor: DesignTokens.errorLight,
              title: 'Hapus Akun',
              subtitle:
                  'Nonaktifkan akun & anonimkan data pribadi dalam 30 hari',
              onTap: _showDeleteAccountDialog,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final Color? color;
  const _SectionTitle(this.text, {this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: color,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    );
  }
}

/// Dialog ganti password dengan validasi lengkap & toggle lihat password.
class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _showOld = false;
  bool _showNew = false;
  String? _error;

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    String? err;
    if (_oldCtrl.text.isEmpty) {
      err = 'Password lama wajib diisi.';
    } else if (_newCtrl.text.length < 8) {
      err = 'Password baru minimal 8 karakter.';
    } else if (_newCtrl.text == _oldCtrl.text) {
      err = 'Password baru harus berbeda dari password lama.';
    } else if (_confirmCtrl.text != _newCtrl.text) {
      err = 'Konfirmasi password baru tidak cocok.';
    }

    if (err != null) {
      setState(() => _error = err);
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ganti Password'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null) ...[
              _DialogError(message: _error!),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _oldCtrl,
              obscureText: !_showOld,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Password Lama',
                suffixIcon: IconButton(
                  tooltip: _showOld ? 'Sembunyikan' : 'Tampilkan',
                  icon: Icon(
                    _showOld
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () => setState(() => _showOld = !_showOld),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newCtrl,
              obscureText: !_showNew,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Password Baru (min. 8 karakter)',
                suffixIcon: IconButton(
                  tooltip: _showNew ? 'Sembunyikan' : 'Tampilkan',
                  icon: Icon(
                    _showNew
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () => setState(() => _showNew = !_showNew),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmCtrl,
              obscureText: !_showNew,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: const InputDecoration(
                labelText: 'Ulangi Password Baru',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

/// Dialog hapus akun (AC-14): wajib konfirmasi password, ada state loading.
class _DeleteAccountDialog extends ConsumerStatefulWidget {
  const _DeleteAccountDialog();

  @override
  ConsumerState<_DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<_DeleteAccountDialog> {
  final _passCtrl = TextEditingController();
  bool _show = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_passCtrl.text.isEmpty) {
      setState(() => _error = 'Konfirmasi password wajib diisi.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final ok = await ref
        .read(appStateProvider.notifier)
        .deleteAccount(_passCtrl.text);
    if (!mounted) return;

    if (!ok) {
      setState(() {
        _loading = false;
        _error = 'Konfirmasi password wajib diisi.';
      });
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hapus Akun Permanen?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Akun akan langsung dinonaktifkan, seluruh sesi perangkat dicabut, dikeluarkan dari leaderboard, dan data pribadi dianonimkan dalam 30 hari.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            if (_error != null) ...[
              _DialogError(message: _error!),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _passCtrl,
              obscureText: !_show,
              enabled: !_loading,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Masukkan Password untuk Konfirmasi',
                suffixIcon: IconButton(
                  tooltip: _show ? 'Sembunyikan' : 'Tampilkan',
                  icon: Icon(
                    _show
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () => setState(() => _show = !_show),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: DesignTokens.errorLight,
            foregroundColor: Colors.white,
          ),
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Hapus Akun Saya'),
        ),
      ],
    );
  }
}

class _DialogError extends StatelessWidget {
  final String message;
  const _DialogError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: DesignTokens.errorLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignTokens.smallRadius),
        border: Border.all(color: DesignTokens.errorLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: DesignTokens.errorLight,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: DesignTokens.errorLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
