import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlquest/shared/models/app_models.dart';
import 'package:sqlquest/shared/widgets/sql_code_editor.dart';
import 'package:sqlquest/shared/widgets/sqlquest_widgets.dart';

import '../../domain/entities/sql_challenge_extensions.dart';
import '../../domain/services/challenge_xp_policy.dart';
import '../controllers/sql_challenge_controller.dart';
import '../controllers/sql_challenge_session.dart';

/// Area input jawaban: toggle mode, Mode Blok atau Mode Editor Teks.
class ChallengeInputSection extends ConsumerWidget {
  const ChallengeInputSection({
    super.key,
    required this.challenge,
    required this.textController,
    required this.isOffline,
    required this.onSubmit,
  });

  final SqlChallengeModel challenge;
  final SqlHighlightingController textController;
  final bool isOffline;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = sqlChallengeControllerProvider(challenge.id);
    final session = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    final showBlocks = session.isBlockMode && challenge.supportsBlockMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (challenge.supportsBlockMode) ...[
          _InputModeToggle(
            isBlockMode: session.isBlockMode,
            onSelectBlocks: () =>
                controller.setInputMode(QueryInputMode.blocks),
            onSelectText: () {
              // Bawa susunan blok ke editor agar pekerjaan tidak hilang.
              final assembled = session.slots.assembledQuery;
              if (session.isBlockMode && assembled.isNotEmpty) {
                textController.text = assembled;
              }
              controller.setInputMode(QueryInputMode.text);
            },
          ),
          const SizedBox(height: 12),
        ],
        if (showBlocks)
          _BlockModeInput(
            challenge: challenge,
            session: session,
            controller: controller,
            isOffline: isOffline,
            onSubmit: onSubmit,
          )
        else
          SqlCodeEditor(
            controller: textController,
            isOffline: isOffline,
            onRun: () => controller.runQuery(textController.text),
            onSubmit: challenge.isAttemptsExhausted ? null : onSubmit,
            submitLabel: 'Jalankan Query',
            submitXpReward: ChallengeXpPolicy.displayedReward(challenge),
            executionResult: session.feedback?.result,
          ),
      ],
    );
  }
}

class _InputModeToggle extends StatelessWidget {
  const _InputModeToggle({
    required this.isBlockMode,
    required this.onSelectBlocks,
    required this.onSelectText,
  });

  final bool isBlockMode;
  final VoidCallback onSelectBlocks;
  final VoidCallback onSelectText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ChoiceChip(
            selected: isBlockMode,
            label: const Text('Mode Blok SQL'),
            onSelected: (_) => onSelectBlocks(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ChoiceChip(
            selected: !isBlockMode,
            label: const Text('Mode Editor Teks'),
            onSelected: (_) => onSelectText(),
          ),
        ),
      ],
    );
  }
}

class _BlockModeInput extends StatelessWidget {
  const _BlockModeInput({
    required this.challenge,
    required this.session,
    required this.controller,
    required this.isOffline,
    required this.onSubmit,
  });

  final SqlChallengeModel challenge;
  final SqlChallengeSession session;
  final SqlChallengeController controller;
  final bool isOffline;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final slots = session.slots;
    final canSubmit =
        !isOffline && slots.isFull && !challenge.isAttemptsExhausted;
    final result = session.feedback?.result;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SqlBlockBuilder(
          slotCount: slots.length,
          filledSlots: slots.items,
          availableBlocks: challenge.blockSet,
          onRemoveSlot: controller.removeBlockAt,
          onSelectBlock: controller.selectBlock,
          onClearAll: controller.clearBlocks,
        ),
        const SizedBox(height: 14),
        // Aktif hanya saat semua slot terisi (Bagian 14 & 19).
        PrimaryActionButton(
          label: 'Jalankan Query',
          xpReward: ChallengeXpPolicy.displayedReward(challenge),
          icon: Icons.play_arrow_rounded,
          onPressed: canSubmit ? onSubmit : null,
        ),
        if (!slots.isFull) ...[
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Isi seluruh slot "?" di atas untuk mengaktifkan tombol Jalankan Query.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
        if (result != null) ...[
          const SizedBox(height: 14),
          SqlExecutionResultView(result: result),
        ],
      ],
    );
  }
}
