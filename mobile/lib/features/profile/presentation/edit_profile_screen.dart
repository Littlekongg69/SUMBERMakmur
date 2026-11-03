import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/models/app_state_provider.dart';
import '../../../shared/widgets/sqlquest_widgets.dart';

/// Bagian 26 & FR-PRF-01:
/// Edit Profile: Nama (2–50 karakter), username unik (3–20 karakter, huruf/angka/_).
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _usernameCtrl;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    final user = ref.read(appStateProvider).user;
    _nameCtrl = TextEditingController(text: user.fullName);
    _usernameCtrl = TextEditingController(text: user.username);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  void _saveProfile() {
    setState(() => _errorMsg = null);
    final err = ref.read(appStateProvider.notifier).updateProfile(
          fullName: _nameCtrl.text,
          username: _usernameCtrl.text,
        );
    if (err != null) {
      setState(() => _errorMsg = err);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: DesignTokens.successLight,
        content: Text('Profil berhasil diperbarui!'),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMsg != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DesignTokens.errorLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: DesignTokens.errorLight),
                  ),
                  child: Text(
                    _errorMsg!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.errorLight,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Text(
                'Nama Lengkap (2–50 karakter)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Username Unik (3–20 karakter, huruf/angka/_)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
              ),
              const Spacer(),
              PrimaryActionButton(
                label: 'Simpan Perubahan',
                icon: Icons.check_rounded,
                onPressed: _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

