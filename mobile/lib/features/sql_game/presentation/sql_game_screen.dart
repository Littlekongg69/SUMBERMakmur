import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/models/app_state_provider.dart';
import '../../../shared/widgets/sqlquest_widgets.dart';

/// Bagian 19 & 37:
/// Layar daftar SQL Game: Query Challenge (20+ tantangan Easy, Medium, Hard, Expert).
class SqlGameScreen extends ConsumerStatefulWidget {
  const SqlGameScreen({super.key});

  @override
  ConsumerState<SqlGameScreen> createState() => _SqlGameScreenState();
}

class _SqlGameScreenState extends ConsumerState<SqlGameScreen> {
  String _difficultyFilter = 'All';

  static const List<String> _difficulties = [
    'All',
    'Easy',
    'Medium',
    'Hard',
    'Expert',
  ];

  Color _difficultyColor(String diff) {
    switch (diff) {
      case 'Easy':
        return DesignTokens.successLight;
      case 'Medium':
        return DesignTokens.primaryLight;
      case 'Hard':
        return DesignTokens.xpRewardLight;
      case 'Expert':
        return DesignTokens.errorLight;
      default:
        return DesignTokens.primaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filtered = state.challenges.where((c) {
      if (_difficultyFilter == 'All') return true;
      return c.difficulty == _difficultyFilter;
    }).toList();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? DesignTokens.darkPageGradient
              : DesignTokens.lightPageGradient,
        ),
        child: SafeArea(
          child: ScreenStateWrapper(
            state: state.simulatedState,
            emptyMessage: 'Belum ada challenge tersedia.',
            onRetry: () => ref
                .read(appStateProvider.notifier)
                .setSimulatedState(ScreenSimulatedState.normal),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SQL Game · Query Challenge',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Uji kemampuan query di sandbox terisolasi & raih XP',
                            style: TextStyle(fontSize: 12.5, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    StatusPill(
                      label:
                          '${state.totalCompletedChallenges}/${state.challenges.length} Selesai',
                      color: DesignTokens.successLight,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Filter tingkat kesulitan
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _difficulties.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final diff = _difficulties[idx];
                      final selected = _difficultyFilter == diff;
                      return ChoiceChip(
                        selected: selected,
                        label: Text(diff == 'All' ? 'Semua Level' : diff),
                        onSelected: (_) =>
                            setState(() => _difficultyFilter = diff),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),

                ...filtered.map((chal) {
                  final diffColor = _difficultyColor(chal.difficulty);
                  final supportsBlocks = chal.blockSet.isNotEmpty;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      onTap: () =>
                          context.push('/game/challenges/${chal.id}'),
                      borderColor: chal.isCompleted
                          ? DesignTokens.successLight.withValues(alpha: 0.5)
                          : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: diffColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  chal.isCompleted
                                      ? Icons.check_circle_rounded
                                      : supportsBlocks
                                          ? Icons.widgets_rounded
                                          : Icons.code_rounded,
                                  color: chal.isCompleted
                                      ? DesignTokens.successLight
                                      : diffColor,
                                ),
                              ),
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
                                          label: chal.difficulty,
                                          color: diffColor,
                                        ),
                                        StatusPill(
                                          label: '+${chal.xpReward} XP',
                                          color: DesignTokens.xpRewardLight,
                                        ),
                                        if (supportsBlocks)
                                          const StatusPill(
                                            label: 'Mode Blok & Teks',
                                            color: Color(0xFF7C3AED),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      chal.title,
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
                          ),
                          const SizedBox(height: 8),
                          Text(
                            chal.description,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.favorite_rounded,
                                size: 14,
                                color: Colors.red.shade400,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                chal.maxAttempts == null
                                    ? 'Percobaan tak terbatas'
                                    : 'Maks ${chal.maxAttempts} percobaan',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Colors.grey,
                                ),
                              ),
                              if (chal.timeLimitSeconds != null) ...[
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.timer_outlined,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${chal.timeLimitSeconds! ~/ 60} menit',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

