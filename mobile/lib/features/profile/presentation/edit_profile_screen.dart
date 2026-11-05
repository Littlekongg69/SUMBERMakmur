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
  late final TextEditingController _nameCtrl;
  late final TextEditingController _usernameCtrl;
  final _usernameFocus = FocusNode();
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
    _usernameFocus.dispose();
    super.dispose();
  }

  void _saveProfile() {
    FocusScope.of(context).unfocus();
    setState(() => _errorMsg = null);
    final err = ref.read(appStateProvider.notifier).updateProfile(
          fullName: _nameCtrl.text.trim(),
          username: _usernameCtrl.text.trim(),
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
    final initial = _nameCtrl.text.trim().isNotEmpty
        ? _nameCtrl.text.trim()[0].toUpperCase()
        : 'U';

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Preview avatar mengikuti inisial nama
                    Center(
                      child: Container(
                        width: 88,
                        height: 88,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: DesignTokens.heroCardGradient,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'Avatar dibuat otomatis dari inisial namamu',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 22),
                    if (_errorMsg != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              DesignTokens.errorLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: DesignTokens.errorLight),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 18,
                              color: DesignTokens.errorLight,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMsg!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: DesignTokens.errorLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const Text(
                      'Nama Lengkap',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameCtrl,
                      maxLength: 50,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _usernameFocus.requestFocus(),
                      decoration: const InputDecoration(
                        hintText: 'Nama lengkapmu',
                        helperText: '2–50 karakter',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Username Unik',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _usernameCtrl,
                      focusNode: _usernameFocus,
                      maxLength: 20,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _saveProfile(),
                      decoration: const InputDecoration(
                        hintText: 'username_kamu',
                        helperText: '3–20 karakter: huruf, angka, atau _',
                        prefixIcon: Icon(Icons.alternate_email_rounded),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: PrimaryActionButton(
                label: 'Simpan Perubahan',
                icon: Icons.check_rounded,
                onPressed: _saveProfile,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
