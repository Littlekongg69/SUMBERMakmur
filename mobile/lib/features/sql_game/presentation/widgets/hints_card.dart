import 'package:flutter/material.dart';
import 'package:sqlquest/core/theme/design_tokens.dart';
import 'package:sqlquest/shared/models/app_models.dart';
import 'package:sqlquest/shared/widgets/sqlquest_widgets.dart';

/// Kartu petunjuk soal dengan label biaya XP (AC-09).
class HintsCard extends StatelessWidget {
  const HintsCard({
    super.key,
    required this.challenge,
    required this.penaltyXp,
    required this.onUnlockNext,
  });

  final SqlChallengeModel challenge;
  final int penaltyXp;
  final VoidCallback onUnlockNext;

  @override
  Widget build(BuildContext context) {
    final opened = challenge.hintsOpened;
    final total = challenge.hints.length;

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 18,
                    color: DesignTokens.xpRewardLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Petunjuk Soal ($opened/$total)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (opened < total)
                TextButton.icon(
                  onPressed: onUnlockNext,
                  icon: const Icon(Icons.lock_open_rounded, size: 16),
                  label: Text(
                    'Tampilkan Petunjuk (-$penaltyXp XP)',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
          for (var i = 0; i < opened; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 8 : 0, bottom: 6),
              child: _HintLine(index: i + 1, text: challenge.hints[i]),
            ),
        ],
      ),
    );
  }
}

class _HintLine extends StatelessWidget {
  const _HintLine({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hint $index: ',
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: DesignTokens.xpRewardLight,
          ),
        ),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12.5))),
      ],
    );
  }
}
