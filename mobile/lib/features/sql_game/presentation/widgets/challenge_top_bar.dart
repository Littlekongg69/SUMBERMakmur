import 'package:flutter/material.dart';
import 'package:sqlquest/core/theme/design_tokens.dart';
import 'package:sqlquest/shared/models/app_models.dart';
import 'package:sqlquest/shared/widgets/sqlquest_widgets.dart';

/// Bar atas: tombol tutup, progres, indikator hati, dan toggle suara.
class ChallengeTopBar extends StatelessWidget {
  const ChallengeTopBar({
    super.key,
    required this.challenge,
    required this.soundEnabled,
    required this.onClose,
    required this.onToggleSound,
  });

  final SqlChallengeModel challenge;
  final bool soundEnabled;
  final VoidCallback onClose;
  final VoidCallback onToggleSound;

  /// Nilai progres saat challenge belum selesai.
  static const double _inProgressValue = 0.65;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Tutup Challenge',
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: challenge.isCompleted ? 1.0 : _inProgressValue,
                  minHeight: 8,
                  backgroundColor: DesignTokens.primaryLight.withValues(
                    alpha: 0.15,
                  ),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    DesignTokens.primaryLight,
                  ),
                ),
              ),
            ),
          ),
          HeartsIndicator(
            remainingHearts: challenge.remainingHearts,
            maxHearts: challenge.maxHeartsDisplay,
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Toggle Suara',
            onPressed: onToggleSound,
            icon: Icon(
              soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
