import 'package:flutter/material.dart';
import 'package:sqlquest/core/theme/design_tokens.dart';
import 'package:sqlquest/shared/models/app_models.dart';
import 'package:sqlquest/shared/widgets/sqlquest_widgets.dart';

/// Bagian informasi challenge: chip konteks (+timer), kartu misi,
/// dan tabel contoh data.
class ChallengeMissionSection extends StatelessWidget {
  const ChallengeMissionSection({
    super.key,
    required this.challenge,
    this.remainingSeconds,
  });

  final SqlChallengeModel challenge;
  final int? remainingSeconds;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ContextChips(challenge: challenge, remainingSeconds: remainingSeconds),
        const SizedBox(height: 12),
        _MissionCard(challenge: challenge),
        const SizedBox(height: 12),
        for (final table in challenge.tables)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TableDataCard(table: table),
          ),
      ],
    );
  }
}

class _ContextChips extends StatelessWidget {
  const _ContextChips({required this.challenge, this.remainingSeconds});

  final SqlChallengeModel challenge;
  final int? remainingSeconds;

  static const int _urgentThresholdSeconds = 60;
  static const Color _timerColor = Color(0xFF0D9488);

  @override
  Widget build(BuildContext context) {
    final seconds = remainingSeconds;

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        StatusPill(
          label: challenge.questContext,
          color: DesignTokens.primaryLight,
        ),
        StatusPill(
          label: challenge.difficulty,
          color: DesignTokens.xpRewardLight,
        ),
        if (seconds != null)
          StatusPill(
            label: 'Waktu: ${_formatCountdown(seconds)}',
            color: seconds < _urgentThresholdSeconds
                ? DesignTokens.errorLight
                : _timerColor,
          ),
      ],
    );
  }

  static String _formatCountdown(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.challenge});

  final SqlChallengeModel challenge;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            challenge.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            challenge.description,
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Theme.of(context).colorScheme.onSurface
                  .withValues(alpha: 0.72),
            ),
          ),
          const Divider(height: 20),
          const Text(
            'Objective:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: DesignTokens.primaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            challenge.objective,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
