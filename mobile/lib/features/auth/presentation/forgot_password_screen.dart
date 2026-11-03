import 'package:flutter/material.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/widgets/sqlquest_widgets.dart';

/// FR-AUTH-04 & Bagian 16:
/// Lupa & reset password dengan tautan sekali pakai berlaku 30 menit (respons anti-enumerasi).
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _sendResetLink() {
    if (_emailCtrl.text.trim().isEmpty) return;
    setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lupa Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reset Password Akun',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masukkan email terdaftar. Kami akan mengirimkan tautan sekali pakai yang berlaku selama 30 menit.',
                style: TextStyle(fontSize: 13.5, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'rani@mail.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 20),
              PrimaryActionButton(
                label: 'Kirim Tautan Reset',
                icon: Icons.send_rounded,
                onPressed: _sendResetLink,
              ),
              if (_sent) ...[
                const SizedBox(height: 20),
                AppCard(
                  borderColor: DesignTokens.successLight,
                  child: const Row(
                    children: [
                      Icon(
                        Icons.mark_email_read_rounded,
                        color: DesignTokens.successLight,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Jika email terdaftar di sistem kami, tautan reset password (berlaku 30 menit) telah dikirimkan.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

