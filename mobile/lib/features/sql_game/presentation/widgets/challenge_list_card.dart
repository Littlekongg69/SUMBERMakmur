import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sqlquest/core/theme/design_tokens.dart';
import 'package:sqlquest/shared/models/app_models.dart';
import 'package:sqlquest/shared/widgets/sqlquest_widgets.dart';

import '../../domain/entities/challenge_difficulty.dart';
import '../../domain/entities/sql_challenge_extensions.dart';
import '../mappers/difficulty_style.dart';

/// Kartu satu challenge pada daftar; membuka layar challenge saat disentuh.
class ChallengeListCard extends StatelessWidget {
  const ChallengeListCard({super.key, required this.challenge});

  final SqlChallengeModel challenge;

  static const Color _blockModeColor = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    final difficultyColor = ChallengeDifficulty.fromKey(challenge.difficulty)
        .color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () => context.push('/game/challenges/${challenge.id}'),
        borderColor: challenge.isCompleted
            ? DesignTokens.successLight.withValues(alpha: 0.5)
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(difficultyColor),
            const SizedBox(height: 8),
            Text(
              challenge.description,
              style: TextStyle(
                fontSize: 12.5,
                color: Theme.of(context).colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            _ChallengeLimits(challenge: challenge),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color difficultyColor) {
    return Row(
      children: [
        _StatusIcon(challenge: challenge, difficultyColor: difficultyColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  StatusPill(
                    label: challenge.difficulty,
                    color: difficultyColor,
                  ),
                  StatusPill(
                    label: '+${challenge.xpReward} XP',
                    color: DesignTokens.xpRewardLight,
                  ),
                  if (challenge.supportsBlockMode)
                    const StatusPill(
                      label: 'Mode Blok & Teks',
                      color: _blockModeColor,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                challenge.title,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded),
      ],
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.challenge, required this.difficultyColor});

  final SqlChallengeModel challenge;
  final Color difficultyColor;

  IconData get _icon {
    if (challenge.isCompleted) return Icons.check_circle_rounded;
    if (challenge.supportsBlockMode) return Icons.widgets_rounded;
    return Icons.code_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: difficultyColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _icon,
        color: challenge.isCompleted
            ? DesignTokens.successLight
            : difficultyColor,
      ),
    );
  }
}

/// Batas percobaan dan (jika ada) batas waktu.
class _ChallengeLimits extends StatelessWidget {
  const _ChallengeLimits({required this.challenge});

  final SqlChallengeModel challenge;

  static const TextStyle _style = TextStyle(fontSize: 11.5, color: Colors.grey);

  @override
  Widget build(BuildContext context) {
    final maxAttempts = challenge.maxAttempts;
    final timeLimit = challenge.timeLimitSeconds;

    return Row(
      children: [
        Icon(Icons.favorite_rounded, size: 14, color: Colors.red.shade400),
        const SizedBox(width: 4),
        Text(
          maxAttempts == null
              ? 'Percobaan tak terbatas'
              : 'Maks $maxAttempts percobaan',
          style: _style,
        ),
        if (timeLimit != null) ...[
          const SizedBox(width: 12),
          const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text('${timeLimit ~/ 60} menit', style: _style),
        ],
      ],
    );
  }
}
