import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sqlquest/core/theme/design_tokens.dart';
import 'package:sqlquest/shared/models/app_models.dart';
import 'package:sqlquest/shared/models/app_state_provider.dart';
import 'package:sqlquest/shared/widgets/sql_code_editor.dart';

import '../domain/entities/sql_result_status.dart';
import '../domain/services/challenge_xp_policy.dart';
import 'controllers/challenge_list_providers.dart';
import 'controllers/sql_challenge_controller.dart';
import 'controllers/sql_challenge_session.dart';
import 'widgets/challenge_input_section.dart';
import 'widgets/challenge_mission_section.dart';
import 'widgets/challenge_not_found_view.dart';
import 'widgets/challenge_top_bar.dart';
import 'widgets/exit_confirmation_dialog.dart';
import 'widgets/hints_card.dart';
import 'widgets/solution_card.dart';

/// Bagian 14 (Layar Game / Challenge Mode Blok & Mode Editor Teks), Bagian 19, 31, 36, & AC-06..AC-09.
///
/// Layar ini hanya menyusun widget; logika sesi (timer, slot blok, run/submit)
/// ada di [SqlChallengeController], dan akses data lewat use case.
class SqlChallengeScreen extends ConsumerWidget {
  const SqlChallengeScreen({super.key, required this.challengeId});

  final String challengeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenge = ref.watch(challengeByIdProvider(challengeId));
    if (challenge == null) return const ChallengeNotFoundView();
    return _ChallengeView(challenge: challenge);
  }
}

class _ChallengeView extends ConsumerStatefulWidget {
  const _ChallengeView({required this.challenge});

  final SqlChallengeModel challenge;

  @override
  ConsumerState<_ChallengeView> createState() => _ChallengeViewState();
}

class _ChallengeViewState extends ConsumerState<_ChallengeView> {
  /// Lebar minimum untuk tata letak dua kolom (Bagian 34).
  static const double _twoColumnBreakpoint = 768;

  final SqlHighlightingController _textController = SqlHighlightingController();

  SqlChallengeModel get _challenge => widget.challenge;

  SqlChallengeController get _controller =>
      ref.read(sqlChallengeControllerProvider(_challenge.id).notifier);

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleClose() async {
    if (_controller.needsExitConfirmation(_textController.text)) {
      final shouldExit = await showExitConfirmationDialog(context);
      if (!shouldExit) return;
    }
    if (mounted) context.pop();
  }

  void _handleSubmit() {
    final submission = _controller.submit(_textController.text);
    if (submission == null || !submission.execution.isCorrect) return;

    final message = submission.xpAwarded > 0
        ? 'Correct! +${submission.xpAwarded} XP ditambahkan!'
        : 'Correct! Query kamu menghasilkan hasil yang benar.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: DesignTokens.successLight,
        content: Text(message),
      ),
    );
  }

  void _toggleSound(bool currentlyEnabled) {
    ref
        .read(appStateProvider.notifier)
        .updatePreferences(soundEnabled: !currentlyEnabled);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sqlChallengeControllerProvider(_challenge.id));
    final soundEnabled = ref.watch(
      appStateProvider.select((s) => s.soundEnabled),
    );
    final isOffline = ref.watch(
      appStateProvider.select(
        (s) => s.simulatedState == ScreenSimulatedState.offline,
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ChallengeTopBar(
              challenge: _challenge,
              soundEnabled: soundEnabled,
              onClose: _handleClose,
              onToggleSound: () => _toggleSound(soundEnabled),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final mission = ChallengeMissionSection(
                    challenge: _challenge,
                    remainingSeconds: session.remainingSeconds,
                  );
                  final workspace = _buildWorkspace(session, isOffline);

                  if (constraints.maxWidth >= _twoColumnBreakpoint) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: mission,
                          ),
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: workspace,
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                    children: [mission, const SizedBox(height: 14), workspace],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkspace(SqlChallengeSession session, bool isOffline) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChallengeInputSection(
          challenge: _challenge,
          textController: _textController,
          isOffline: isOffline,
          onSubmit: _handleSubmit,
        ),
        const SizedBox(height: 14),
        HintsCard(
          challenge: _challenge,
          penaltyXp: ChallengeXpPolicy.hintPenalty(_challenge),
          onUnlockNext: _controller.unlockNextHint,
        ),
        if (session.revealsSolutionFor(_challenge)) ...[
          const SizedBox(height: 14),
          SolutionCard(
            challenge: _challenge,
            feedback: session.feedback,
            onResetAttempts: _controller.resetAttempts,
          ),
        ],
      ],
    );
  }
}
