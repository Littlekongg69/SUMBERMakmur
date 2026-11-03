import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/models/app_state_provider.dart';
import '../../../shared/models/seed_data.dart';
import '../../../shared/widgets/sqlquest_widgets.dart';

/// Bagian 24 & AC-13:
/// Leaderboard dengan tab Global, Weekly, Monthly.
/// Menampilkan Top 50 dan baris "Kamu" yang selalu terlihat dengan rank sebenarnya.
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  String _periodType = 'global'; // global, weekly, monthly

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final entries = SeedData.buildLeaderboard(
      currentUser: state.user,
      periodType: _periodType,
    );
    final myEntry = entries.firstWhere(
      (e) => e.isCurrentUser,
      orElse: () => entries.first,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Peringkat (Leaderboard)')),
      body: ScreenStateWrapper(
        state: state.simulatedState,
        emptyMessage: 'Belum ada data peringkat.',
        onRetry: () => ref
            .read(appStateProvider.notifier)
            .setSimulatedState(ScreenSimulatedState.normal),
        child: Column(
          children: [
            // Tab Global, Weekly, Monthly
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      selected: _periodType == 'global',
                      label: const Center(child: Text('Global')),
                      onSelected: (_) =>
                          setState(() => _periodType = 'global'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      selected: _periodType == 'weekly',
                      label: const Center(child: Text('Weekly')),
                      onSelected: (_) =>
                          setState(() => _periodType = 'weekly'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      selected: _periodType == 'monthly',
                      label: const Center(child: Text('Monthly')),
                      onSelected: (_) =>
                          setState(() => _periodType = 'monthly'),
                    ),
                  ),
                ],
              ),
            ),

            if (state.user.hideFromLeaderboard || !state.user.emailVerified)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  !state.user.emailVerified
                      ? 'Akun belum verifikasi email: kamu tetap dapat melihat posisi sendiri tetapi disembunyikan dari daftar publik (FR-AUTH-02).'
                      : 'Privasi aktif: profil kamu disembunyikan dari daftar publik (Bagian 24).',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: entries.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = entries[index];
                  return _LeaderboardRowWidget(entry: item);
                },
              ),
            ),

            // Sticky "Kamu" Row (AC-13)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: _LeaderboardRowWidget(
                entry: myEntry,
                labelOverride: 'Kamu (@${myEntry.username})',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardRowWidget extends StatelessWidget {
  final LeaderboardEntryModel entry;
  final String? labelOverride;

  const _LeaderboardRowWidget({
    required this.entry,
    this.labelOverride,
  });

  @override
  Widget build(BuildContext context) {
    final highlight = entry.isCurrentUser;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderColor: highlight ? DesignTokens.primaryLight : null,
      borderWidth: highlight ? 2 : 1,
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: entry.rank <= 3
                    ? DesignTokens.xpRewardLight
                    : DesignTokens.primaryLight,
              ),
            ),
          ),
          CircleAvatar(
            radius: 17,
            backgroundColor: highlight
                ? DesignTokens.primaryLight
                : DesignTokens.primaryLight.withValues(alpha: 0.14),
            child: Text(
              entry.username[0].toUpperCase(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: highlight ? Colors.white : DesignTokens.primaryLight,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  labelOverride ?? '@${entry.username}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Level ${entry.level}',
                  style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (entry.rankChange != 0) ...[
            Icon(
              entry.rankChange > 0
                  ? Icons.arrow_drop_up_rounded
                  : Icons.arrow_drop_down_rounded,
              color: entry.rankChange > 0
                  ? DesignTokens.successLight
                  : DesignTokens.errorLight,
            ),
            Text(
              '${entry.rankChange.abs()}',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: entry.rankChange > 0
                    ? DesignTokens.successLight
                    : DesignTokens.errorLight,
              ),
            ),
            const SizedBox(width: 10),
          ],
          StatusPill(
            label: '${entry.xp} XP',
            color: DesignTokens.xpRewardLight,
          ),
        ],
      ),
    );
  }
}

