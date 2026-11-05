import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/models/app_state_provider.dart';
import '../../../shared/widgets/sqlquest_widgets.dart';

enum _AchievementFilter { all, unlocked, locked }

/// Bagian 23 & 33:
/// Layar Achievement menampilkan daftar badge terbuka (berwarna) dan terkunci (abu-abu),
/// dilengkapi ringkasan progres dan filter Semua / Terbuka / Terkunci.
class AchievementScreen extends ConsumerStatefulWidget {
  const AchievementScreen({super.key});

  @override
  ConsumerState<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends ConsumerState<AchievementScreen> {
  _AchievementFilter _filter = _AchievementFilter.all;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final achievements = state.achievements;
    final total = achievements.length;
    final unlocked = state.unlockedBadgesCount;
    final ratio = total == 0 ? 0.0 : unlocked / total;

    final visible = achievements.where((a) {
      switch (_filter) {
        case _AchievementFilter.all:
          return true;
        case _AchievementFilter.unlocked:
          return a.isUnlocked;
        case _AchievementFilter.locked:
          return !a.isUnlocked;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Pencapaian & Badge')),
      body: ScreenStateWrapper(
        state: state.simulatedState,
        emptyMessage: 'Belum ada achievement. Selesaikan lesson pertamamu!',
        onRetry: () => ref
            .read(appStateProvider.notifier)
            .setSimulatedState(ScreenSimulatedState.normal),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            // Ringkasan progres
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Total Badge Terbuka',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      StatusPill(
                        label: '$unlocked / $total Didapat',
                        color: DesignTokens.xpRewardLight,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  XpProgressBar(
                    progress: ratio,
                    leftLabel: '$unlocked dari $total badge',
                    rightLabel: '${(ratio * 100).round()}%',
                    color: DesignTokens.xpRewardLight,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Filter
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _filterChip('Semua ($total)', _AchievementFilter.all),
                _filterChip(
                  'Terbuka ($unlocked)',
                  _AchievementFilter.unlocked,
                ),
                _filterChip(
                  'Terkunci (${total - unlocked})',
                  _AchievementFilter.locked,
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (visible.isEmpty)
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      _filter == _AchievementFilter.unlocked
                          ? 'Belum ada badge terbuka. Selesaikan lesson pertamamu!'
                          : 'Semua badge sudah terbuka. Hebat!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ),
              )
            else
              ...visible.map(
                (ach) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AchievementTile(achievement: ach),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, _AchievementFilter value) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (_) => setState(() => _filter = value),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final AchievementModel achievement;
  const _AchievementTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final ach = achievement;
    final unlocked = ach.isUnlocked;

    return AppCard(
      borderColor:
          unlocked ? DesignTokens.xpRewardLight.withValues(alpha: 0.6) : null,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked
                  ? DesignTokens.xpRewardLight.withValues(alpha: 0.16)
                  : Colors.grey.withValues(alpha: 0.15),
            ),
            child: Icon(
              unlocked ? _achievementIcon(ach.iconName) : Icons.lock_outline_rounded,
              color: unlocked ? DesignTokens.xpRewardLight : Colors.grey,
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
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      ach.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: unlocked ? null : Colors.grey,
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
                  style: const TextStyle(fontSize: 12.5, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusPill(
            label: unlocked ? '+${ach.xpReward} XP' : 'Terkunci',
            color: unlocked ? DesignTokens.successLight : Colors.grey,
          ),
        ],
      ),
    );
  }
}

/// Pemetaan ikon sama dengan BadgeTile di layar Profil agar konsisten.
IconData _achievementIcon(String? iconName) {
  switch (iconName) {
    case 'menu_book':
      return Icons.menu_book_rounded;
    case 'terminal':
      return Icons.terminal_rounded;
    case 'sports_esports':
      return Icons.sports_esports_rounded;
    case 'workspace_premium':
      return Icons.workspace_premium_rounded;
    case 'local_fire_department':
      return Icons.local_fire_department_rounded;
    case 'military_tech':
      return Icons.military_tech_rounded;
    default:
      return Icons.emoji_events_rounded;
  }
}
