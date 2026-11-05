import 'package:flutter/material.dart';
import 'package:sqlquest/core/theme/app_theme.dart';
import 'package:sqlquest/core/theme/design_tokens.dart';
import 'package:sqlquest/shared/models/app_models.dart';
import 'package:sqlquest/shared/widgets/sqlquest_widgets.dart';

import '../controllers/sql_challenge_session.dart';

/// Penjelasan & query referensi (AC-06, AC-07), ditampilkan setelah
/// challenge selesai atau percobaan habis.
class SolutionCard extends StatelessWidget {
  const SolutionCard({
    super.key,
    required this.challenge,
    required this.feedback,
    required this.onResetAttempts,
  });

  final SqlChallengeModel challenge;
  final QueryFeedback? feedback;
  final VoidCallback onResetAttempts;

  static const Color _codeBackground = Color(0xFF0F172A);
  static const Color _codeForeground = Color(0xFF4ADE80);

  @override
  Widget build(BuildContext context) {
    final earned = feedback;

    return AppCard(
      borderColor: DesignTokens.successLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Penjelasan & Query Referensi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.successLight,
                ),
              ),
              if (earned != null && earned.hasEarnedXp)
                StatusPill(
                  label: '+${earned.awardedXp} XP Diterima',
                  color: DesignTokens.xpRewardLight,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(challenge.explanation, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _codeBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              challenge.referenceQuery,
              style: AppTheme.monoStyle(fontSize: 12.5, color: _codeForeground),
            ),
          ),
          if (challenge.isAttemptsExhausted) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onResetAttempts,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reset Sesi Percobaan'),
            ),
          ],
        ],
      ),
    );
  }
}
