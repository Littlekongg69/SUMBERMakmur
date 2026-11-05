import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlquest/core/theme/design_tokens.dart';
import 'package:sqlquest/shared/models/app_models.dart';
import 'package:sqlquest/shared/models/app_state_provider.dart';
import 'package:sqlquest/shared/widgets/sqlquest_widgets.dart';

import '../domain/entities/challenge_difficulty.dart';
import 'controllers/challenge_list_providers.dart';
import 'controllers/difficulty_filter_controller.dart';
import 'widgets/challenge_list_card.dart';
import 'widgets/difficulty_filter_bar.dart';
import 'widgets/sql_game_header.dart';

/// Bagian 19 & 37:
/// Layar daftar SQL Game: Query Challenge (20+ tantangan Easy, Medium, Hard, Expert).
class SqlGameScreen extends ConsumerWidget {
  const SqlGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filter = ref.watch(difficultyFilterProvider);
    final allChallenges = ref.watch(
      challengeListProvider(ChallengeDifficulty.all),
    );
    final visibleChallenges = ref.watch(challengeListProvider(filter));
    final screenState = ref.watch(
      appStateProvider.select((s) => s.simulatedState),
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? DesignTokens.darkPageGradient
              : DesignTokens.lightPageGradient,
        ),
        child: SafeArea(
          child: ScreenStateWrapper(
            state: screenState,
            emptyMessage: 'Belum ada challenge tersedia.',
            onRetry: () => ref
                .read(appStateProvider.notifier)
                .setSimulatedState(ScreenSimulatedState.normal),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                SqlGameHeader(
                  completedCount: allChallenges
                      .where((c) => c.isCompleted)
                      .length,
                  totalCount: allChallenges.length,
                ),
                const SizedBox(height: 14),
                DifficultyFilterBar(
                  selected: filter,
                  onSelected: ref
                      .read(difficultyFilterProvider.notifier)
                      .select,
                ),
                const SizedBox(height: 14),
                for (final challenge in visibleChallenges)
                  ChallengeListCard(challenge: challenge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
