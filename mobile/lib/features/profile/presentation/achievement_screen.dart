import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/models/app_state_provider.dart';
import '../../../shared/widgets/sqlquest_widgets.dart';

/// Bagian 23 & 33:
/// Layar Achievement menampilkan daftar badge terbuka (berwarna, tanggal buka) dan terkunci (abu-abu).
class AchievementScreen extends ConsumerWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final achievements = state.achievements;

    return Scaffold(
      appBar: AppBar(title: const Text('Pencapaian & Badge')),
      body: ScreenStateWrapper(
        state: state.simulatedState,
        emptyMessage:
            'Belum ada achievement. Selesaikan lesson pertamamu!',
        onRetry: () => ref
            .read(appStateProvider.notifier)
            .setSimulatedState(ScreenSimulatedState.normal),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Badge Terbuka',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  StatusPill(
                    label:
                        '${state.unlockedBadgesCount} / ${achievements.length} Didapat',
                    color: DesignTokens.xpRewardLight,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ...achievements.map((ach) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  borderColor: ach.isUnlocked
                      ? DesignTokens.xpRewardLight.withValues(alpha: 0.6)
                      : null,
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ach.isUnlocked
                              ? DesignTokens.xpRewardLight
                                  .withValues(alpha: 0.16)
                              : Colors.grey.withValues(alpha: 0.15),
                        ),
                        child: Icon(
                          ach.isUnlocked
                              ? Icons.emoji_events_rounded
                              : Icons.lock_outline_rounded,
                          color: ach.isUnlocked
                              ? DesignTokens.xpRewardLight
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 6,
                              children: [
                                Text(
                                  ach.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: ach.isUnlocked ? null : Colors.grey,
                                  ),
                                ),
                                if (ach.isMvp)
                                  const StatusPill(
                                    label: 'MVP',
                                    color: DesignTokens.primaryLight,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ach.description,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusPill(
                        label: ach.isUnlocked
                            ? '+${ach.xpReward} XP'
                            : 'Terkunci',
                        color: ach.isUnlocked
                            ? DesignTokens.successLight
                            : Colors.grey,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

