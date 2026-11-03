import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/utils/sql_sandbox_engine.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/models/app_state_provider.dart';
import '../../../shared/widgets/sql_code_editor.dart';
import '../../../shared/widgets/sqlquest_widgets.dart';

/// Bagian 14 (Layar Game / Challenge Mode Blok & Mode Editor Teks), Bagian 19, 31, 36, & AC-06..AC-09:
/// - Bar atas: Tombol tutup (konfirmasi bila ada jawaban belum dikirim), progress langkah, indikator hati, toggle suara
/// - Chip konteks: Nama quest, nomor misi, modul terkait
/// - Kartu misi: Judul, cerita singkat, objective
/// - Kartu tabel: TableDataCard (scroll horizontal, integer tanpa desimal)
/// - Mode Blok ("Susun Query" + "Pilihan Blok SQL" + tombol "Jalankan Query" aktif hanya saat semua slot terisi)
/// - Mode Editor Teks (MOB-06: syntax highlighting, Run & Submit, toolbar kata kunci SQL)
/// - Tampilkan Petunjuk Soal dengan label biaya XP (-10% XP dasar per hint)
class SqlChallengeScreen extends ConsumerStatefulWidget {
  final String challengeId;

  const SqlChallengeScreen({
    super.key,
    required this.challengeId,
  });

  @override
  ConsumerState<SqlChallengeScreen> createState() => _SqlChallengeScreenState();
}

class _SqlChallengeScreenState extends ConsumerState<SqlChallengeScreen> {
  late bool _useBlockMode;
  late List<SqlBlockItem?> _filledSlots;
  late SqlHighlightingController _textController;
  SandboxExecutionResult? _lastResult;
  int? _lastAwardedXp;
  Timer? _countdownTimer;
  int? _remainingSeconds;
  bool _hasUnsavedInput = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(appStateProvider);
    final chal = state.challenges.cast<SqlChallengeModel?>().firstWhere(
          (c) => c!.id == widget.challengeId,
          orElse: () => state.challenges.first,
        )!;

    _useBlockMode = chal.blockSet.isNotEmpty;
    _filledSlots = List<SqlBlockItem?>.filled(
      chal.targetSlotCount > 0 ? chal.targetSlotCount : 6,
      null,
    );
    _textController = SqlHighlightingController();
    _textController.addListener(() {
      if (_textController.text.trim().isNotEmpty && !_hasUnsavedInput) {
        setState(() => _hasUnsavedInput = true);
      }
    });

    if (chal.timeLimitSeconds != null) {
      _remainingSeconds = chal.timeLimitSeconds;
      _startTimer();
    }
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _remainingSeconds == null) return;
      if (_remainingSeconds! <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
          _lastResult = const SandboxExecutionResult(
            resultStatus: 'time_up',
            message: 'Waktu habis. Coba lagi untuk skor terbaik.',
          );
        });
      } else {
        setState(() => _remainingSeconds = _remainingSeconds! - 1);
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  bool get _areAllSlotsFilled =>
      _filledSlots.isNotEmpty && _filledSlots.every((slot) => slot != null);

  String get _assembledBlockQuery {
    return _filledSlots
        .whereType<SqlBlockItem>()
        .map((b) => b.text)
        .join(' ')
        .replaceAll(' ;', ';');
  }

  Future<void> _handleCloseButton() async {
    final hasWork = _useBlockMode
        ? _filledSlots.any((s) => s != null)
        : _textController.text.trim().isNotEmpty;

    if (hasWork && _lastResult?.resultStatus != 'correct') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Keluar dari Challenge?'),
          content: const Text(
            'Kamu memiliki susunan query yang belum dikirim. Yakin ingin menutup challenge ini?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Lanjut Mengerjakan'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Keluar'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }
    if (mounted) context.pop();
  }

  void _runQueryOnly(SqlChallengeModel chal) {
    final query =
        _useBlockMode ? _assembledBlockQuery : _textController.text;
    final res = SqlSandboxEngine.execute(
      rawQuery: query,
      tables: chal.tables,
      referenceQuery: chal.referenceQuery,
      expectedColumns: chal.expectedColumns,
      expectedRows: chal.expectedRows,
      ordered: chal.ordered,
      strictColumns: chal.strictColumns,
      allowDml: chal.allowDml,
      isSubmit: false,
    );
    setState(() {
      _lastResult = res;
      _lastAwardedXp = null;
    });
  }

  void _submitChallenge(SqlChallengeModel chal) {
    if (_remainingSeconds != null && _remainingSeconds! <= 0) {
      setState(() {
        _lastResult = const SandboxExecutionResult(
          resultStatus: 'time_up',
          message: 'Waktu habis. Coba lagi untuk skor terbaik.',
        );
      });
      return;
    }

    final query =
        _useBlockMode ? _assembledBlockQuery : _textController.text;
    final outcome = ref.read(appStateProvider.notifier).submitChallengeQuery(
          challengeId: chal.id,
          query: query,
        );

    setState(() {
      _lastResult = outcome.execution;
      _lastAwardedXp = outcome.xpAwarded;
      _hasUnsavedInput = false;
    });

    if (outcome.execution.resultStatus == 'correct') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: DesignTokens.successLight,
          content: Text(
            outcome.xpAwarded > 0
                ? 'Correct! +${outcome.xpAwarded} XP ditambahkan!'
                : 'Correct! Query kamu menghasilkan hasil yang benar.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final chal = state.challenges.cast<SqlChallengeModel?>().firstWhere(
          (c) => c!.id == widget.challengeId,
          orElse: () => null,
        );
    final isOffline = state.simulatedState == ScreenSimulatedState.offline;

    if (chal == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Challenge Tidak Ditemukan (404)')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Kembali ke Beranda'),
          ),
        ),
      );
    }

    final hintPenaltyXp = (chal.xpReward * 0.10).round().clamp(1, 50);
    final currentPotentialXp = SqlSandboxEngine.calculateChallengeXp(
      baseXp: chal.xpReward,
      attemptNumber: chal.attemptsUsed + 1,
      hintsUsed: chal.hintsOpened,
      alreadySolvedBefore: chal.isCompleted,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 1. Bar Atas (Bagian 14: Tombol tutup, progress langkah, indikator hati, toggle suara)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Tutup Challenge',
                    onPressed: _handleCloseButton,
                    icon: const Icon(Icons.close_rounded),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: chal.isCompleted ? 1.0 : 0.65,
                          minHeight: 8,
                          backgroundColor:
                              DesignTokens.primaryLight.withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            DesignTokens.primaryLight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  HeartsIndicator(
                    remainingHearts: chal.remainingHearts,
                    maxHearts: chal.maxHeartsDisplay,
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Toggle Suara',
                    onPressed: () {
                      ref.read(appStateProvider.notifier).updatePreferences(
                            soundEnabled: !state.soundEnabled,
                          );
                    },
                    icon: Icon(
                      state.soundEnabled
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Konten Utama (Responsive 1 atau 2 kolom sesuai Bagian 34)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isTwoCol = constraints.maxWidth >= 768;
                  if (isTwoCol) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: _buildMissionAndTableSection(chal),
                          ),
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: _buildInputAndFeedbackSection(
                              chal,
                              hintPenaltyXp: hintPenaltyXp,
                              currentPotentialXp: currentPotentialXp,
                              isOffline: isOffline,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                    children: [
                      _buildMissionAndTableSection(chal),
                      const SizedBox(height: 14),
                      _buildInputAndFeedbackSection(
                        chal,
                        hintPenaltyXp: hintPenaltyXp,
                        currentPotentialXp: currentPotentialXp,
                        isOffline: isOffline,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionAndTableSection(SqlChallengeModel chal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 2. Chip Konteks (Nama quest, nomor misi, modul terkait + timer jika ada)
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            StatusPill(
              label: chal.questContext,
              color: DesignTokens.primaryLight,
            ),
            StatusPill(
              label: chal.difficulty,
              color: DesignTokens.xpRewardLight,
            ),
            if (_remainingSeconds != null)
              StatusPill(
                label:
                    'Waktu: ${(_remainingSeconds! ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds! % 60).toString().padLeft(2, '0')}',
                color: _remainingSeconds! < 60
                    ? DesignTokens.errorLight
                    : const Color(0xFF0D9488),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // 3. Kartu Misi (Judul, cerita singkat, objective)
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chal.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                chal.description,
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.72),
                ),
              ),
              const Divider(height: 20),
              const Text(
                'Objective:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.primaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                chal.objective,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 4. Kartu Tabel Contoh (TableDataCard)
        ...chal.tables.map((t) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TableDataCard(table: t),
          );
        }),
      ],
    );
  }

  Widget _buildInputAndFeedbackSection(
    SqlChallengeModel chal, {
    required int hintPenaltyXp,
    required int currentPotentialXp,
    required bool isOffline,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle antara Mode Blok dan Mode Editor Teks bila challenge mendukung blok
        if (chal.blockSet.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  selected: _useBlockMode,
                  label: const Text('Mode Blok SQL'),
                  onSelected: (_) => setState(() => _useBlockMode = true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  selected: !_useBlockMode,
                  label: const Text('Mode Editor Teks'),
                  onSelected: (_) {
                    if (_useBlockMode && _assembledBlockQuery.isNotEmpty) {
                      _textController.text = _assembledBlockQuery;
                    }
                    setState(() => _useBlockMode = false);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // 5. Area Input: Mode Blok ("Susun Query" + "Pilihan Blok SQL") ATAU Mode Editor Teks
        if (_useBlockMode && chal.blockSet.isNotEmpty) ...[
          SqlBlockBuilder(
            slotCount: _filledSlots.length,
            filledSlots: _filledSlots,
            availableBlocks: chal.blockSet,
            onRemoveSlot: (slotIndex) {
              setState(() {
                _filledSlots[slotIndex] = null;
              });
            },
            onSelectBlock: (block) {
              final emptyIdx = _filledSlots.indexWhere((s) => s == null);
              if (emptyIdx != -1) {
                setState(() {
                  _filledSlots[emptyIdx] = block;
                  _hasUnsavedInput = true;
                });
              }
            },
            onClearAll: () {
              setState(() {
                for (int i = 0; i < _filledSlots.length; i++) {
                  _filledSlots[i] = null;
                }
              });
            },
          ),
          const SizedBox(height: 14),

          // Tombol "Jalankan Query" dengan label XP hadiah; AKTIF HANYA SAAT SEMUA SLOT TERISI (Bagian 14 & 19)
          PrimaryActionButton(
            label: 'Jalankan Query',
            xpReward: currentPotentialXp > 0 ? currentPotentialXp : chal.xpReward,
            icon: Icons.play_arrow_rounded,
            onPressed: (!isOffline &&
                    _areAllSlotsFilled &&
                    !chal.isAttemptsExhausted)
                ? () => _submitChallenge(chal)
                : null,
          ),
          if (!_areAllSlotsFilled) ...[
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'Isi seluruh slot "?" di atas untuk mengaktifkan tombol Jalankan Query.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
          if (_lastResult != null) ...[
            const SizedBox(height: 14),
            SqlExecutionResultView(result: _lastResult!),
          ],
        ] else ...[
          SqlCodeEditor(
            controller: _textController,
            isOffline: isOffline,
            onRun: () => _runQueryOnly(chal),
            onSubmit: chal.isAttemptsExhausted
                ? null
                : () => _submitChallenge(chal),
            submitLabel: 'Jalankan Query',
            submitXpReward:
                currentPotentialXp > 0 ? currentPotentialXp : chal.xpReward,
            executionResult: _lastResult,
          ),
        ],

        const SizedBox(height: 14),

        // 6. Tombol "Tampilkan Petunjuk Soal" dengan label biaya XP (AC-09)
        AppCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 18,
                        color: DesignTokens.xpRewardLight,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Petunjuk Soal (${chal.hintsOpened}/${chal.hints.length})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (chal.hintsOpened < chal.hints.length)
                    TextButton.icon(
                      onPressed: () {
                        ref
                            .read(appStateProvider.notifier)
                            .unlockNextHint(chal.id);
                      },
                      icon: const Icon(Icons.lock_open_rounded, size: 16),
                      label: Text(
                        'Tampilkan Petunjuk (-$hintPenaltyXp XP)',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
              if (chal.hintsOpened > 0) ...[
                const SizedBox(height: 8),
                ...List.generate(chal.hintsOpened, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hint ${i + 1}: ',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: DesignTokens.xpRewardLight,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            chal.hints[i],
                            style: const TextStyle(fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),

        // 7. Penjelasan & Query Referensi saat selesai atau percobaan habis (Bagian 19 & AC-06, AC-07)
        if (chal.isCompleted ||
            chal.isAttemptsExhausted ||
            _lastResult?.resultStatus == 'correct' ||
            _lastResult?.resultStatus == 'attempts_exhausted') ...[
          const SizedBox(height: 14),
          AppCard(
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
                    if (_lastAwardedXp != null && _lastAwardedXp! > 0)
                      StatusPill(
                        label: '+$_lastAwardedXp XP Diterima',
                        color: DesignTokens.xpRewardLight,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  chal.explanation,
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    chal.referenceQuery,
                    style: AppTheme.monoStyle(
                      fontSize: 12.5,
                      color: const Color(0xFF4ADE80),
                    ),
                  ),
                ),
                if (chal.isAttemptsExhausted) ...[
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {
                      ref
                          .read(appStateProvider.notifier)
                          .resetChallengeAttempts(chal.id);
                      setState(() => _lastResult = null);
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Reset Sesi Percobaan'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

