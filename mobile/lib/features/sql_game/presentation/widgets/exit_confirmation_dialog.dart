import 'package:flutter/material.dart';

/// Meminta konfirmasi keluar saat ada query yang belum dikirim.
/// Mengembalikan `true` bila pengguna memilih keluar.
Future<bool> showExitConfirmationDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Keluar dari Challenge?'),
      content: const Text(
        'Kamu memiliki susunan query yang belum dikirim. '
        'Yakin ingin menutup challenge ini?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Lanjut Mengerjakan'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Keluar'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
