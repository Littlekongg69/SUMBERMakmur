import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Tampilan 404 saat ID challenge tidak ditemukan.
class ChallengeNotFoundView extends StatelessWidget {
  const ChallengeNotFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Challenge Tidak Ditemukan (404)')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.go('/home'),
          child: const Text('Kembali ke Beranda'),
        ),
      ),
    );
  }
}
