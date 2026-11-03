import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/models/app_state_provider.dart';
import '../../../shared/widgets/sqlquest_widgets.dart';

/// Bagian 20 & AC-10:
/// Layar Daily Mission: 3 misi harian per pengguna (1 mudah, 1 sedang, 1 bebas),
/// reset pada 00:00 waktu lokal pengguna, bonus +30 XP bila ketiga misi selesai.
class DailyMissionScreen extends ConsumerWidget {
  const DailyMissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final missions = state.dailyMissions;
    final allDone = missions.every((m) => m.status == 'completed');

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final hoursLeft = midnight.difference(now).inHours;
    final minsLeft = midnight.difference(now).inMinutes % 60;

    return Scaffold(
      appBar: AppBar(title: const Text('Tantangan Harian')),
      body: ScreenStateWrapper(
        state: state.simulatedState,
        emptyMessage: 'Belum ada misi harian.',
        onRetry: () => ref
            .read(appStateProvider.notifier)
            .setSimulatedState(ScreenSimulatedState.normal),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              gradient: DesignTokens.heroCardGradient,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Misi Harian Kamu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius:
                              BorderRadius.circular(DesignTokens.pillRadius),
                        ),
                        child: Text(
                          'Reset dalam ${hoursLeft}j ${minsLeft}m',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    allDone
                        ? 'Luar biasa! Ketiga misi harian selesai (+30 XP Bonus diklaim).'
                        : 'Selesaikan ketiga misi sebelum pukul 00:00 (${state.user.timezone}) untuk bonus ekstra +30 XP!',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...missions.map((m) {
              final isDone = m.status == 'completed';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  borderColor: isDone ? DesignTokens.successLight : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          StatusPill(
                            label: m.difficulty,
                            color: DesignTokens.primaryLight,
                          ),
                          const SizedBox(width: 8),
                          StatusPill(
                            label: '+${m.xpReward} XP',
                            color: DesignTokens.xpRewardLight,
                          ),
                          const Spacer(),
                          Icon(
                            isDone
                                ? Icons.check_circle_rounded
                                : Icons.timelapse_rounded,
                            color: isDone
                                ? DesignTokens.successLight
                                : Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        m.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        m.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      XpProgressBar(
                        progress: m.progressRatio,
                        leftLabel: isDone ? 'Completed' : 'Progress',
                        rightLabel: '${m.progress} / ${m.target}',
                        color: isDone
                            ? DesignTokens.successLight
                            : DesignTokens.xpRewardLight,
                      ),
                      if (!isDone) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              final earned = ref
                                  .read(appStateProvider.notifier)
                                  .claimDailyMission(m.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: DesignTokens.successLight,
                                  content: Text(
                                    'Misi selesai! +$earned XP ditambahkan.',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.bolt_rounded,
                              size: 18,
                            ),
                            label: const Text('Selesaikan & Klaim XP'),
                          ),
                        ),
                      ],
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

