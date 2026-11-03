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

/// Bagian 17, FR-LRN-02, FR-LRN-03, MOB-04, Bagian 34 (Responsive LayoutBuilder), & AC-05:
/// Layar Lesson berisi materi, contoh kode SQL, skema tabel, editor SQL interaktif,
/// tautan ke Kuis Lesson, dan tombol Selesaikan Lesson.
///
/// Perubahan desain:
/// - Tombol "Selesaikan Lesson" dipindah ke bar bawah yang selalu terlihat,
///   lengkap dengan hitungan syarat yang sudah terpenuhi.
/// - Contoh kode dapat di-scroll horizontal (tidak lagi dipaksa wrap).
/// - Judul lesson tidak lagi diulang di AppBar dan kartu materi.
/// - Label internal "(AC-05)" dihapus dari UI pengguna.
class LessonScreen extends ConsumerStatefulWidget {
  final String lessonId;

  const LessonScreen({
    super.key,
    required this.lessonId,
  });

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  late SqlHighlightingController _queryController;
  SandboxExecutionResult? _executionResult;

  @override
  void initState() {
    super.initState();
    final lesson = ref.read(appStateProvider).findLessonById(widget.lessonId);
    _queryController = SqlHighlightingController(
      text: lesson?.starterQuery ?? 'SELECT * FROM users;',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(appStateProvider.notifier)
          .cacheLessonForOffline(widget.lessonId);
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _runPracticeQuery(LessonModel lesson) {
    final res = SqlSandboxEngine.execute(
      rawQuery: _queryController.text,
      tables: lesson.sandboxTables,
      referenceQuery: lesson.referenceQuery,
      expectedColumns: lesson.expectedColumns,
      expectedRows: lesson.expectedRows,
      isSubmit: false,
    );
    setState(() => _executionResult = res);
    if (res.resultStatus == 'ok' || res.resultStatus == 'correct') {
      ref
          .read(appStateProvider.notifier)
          .markLessonQueryExecuted(lesson.id);
    }
  }

  void _completeLesson(LessonModel lesson) {
    final outcome =
    ref.read(appStateProvider.notifier).completeLesson(lesson.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: outcome.success
            ? DesignTokens.successLight
            : DesignTokens.errorLight,
        content: Text(outcome.message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final lesson = state.findLessonById(widget.lessonId);
    final isOffline = state.simulatedState == ScreenSimulatedState.offline;

    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Konten tidak ditemukan (404)')),
        body: Center(
          child: FilledButton(
            onPressed: () => context.go('/home'),
            child: const Text('Kembali ke Beranda'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Lesson ${lesson.position}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: StatusPill(
              label: '+${lesson.xpReward} XP',
              color: DesignTokens.xpRewardLight,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _CompletionBar(
        lesson: lesson,
        onComplete: () => _completeLesson(lesson),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Bagian 34: Tablet (768px ke atas) memakai dua kolom pada lesson dan challenge
          final isTwoColumn = constraints.maxWidth >= 768;
          if (isTwoColumn) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildTheoryPanel(lesson, state),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildPracticePanel(lesson, isOffline: isOffline),
                  ),
                ),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _buildTheoryPanel(lesson, state),
              const SizedBox(height: 24),
              _buildPracticePanel(lesson, isOffline: isOffline),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTheoryPanel(LessonModel lesson, AppState state) {
    final isCached = state.cachedLessonIds.contains(lesson.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lesson.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            StatusPill(
              label: lesson.difficulty,
              color: DesignTokens.primaryLight,
            ),
            StatusPill(
              label: '${lesson.estimatedMinutes} menit',
              color: DesignTokens.successLight,
            ),
            if (isCached)
              const StatusPill(
                label: 'Tersimpan offline',
                color: Color(0xFF0D9488),
              ),
          ],
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: const EdgeInsets.all(18),
          child: Text(
            lesson.contentMarkdown.trim(),
            style: const TextStyle(fontSize: 15, height: 1.6),
          ),
        ),
        if (lesson.codeExamples.isNotEmpty) ...[
          const SizedBox(height: 20),
          const _PanelTitle('Contoh kode SQL'),
          const SizedBox(height: 8),
          ...lesson.codeExamples.map(
                (code) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CodeExample(
                code: code,
                onCopy: () {
                  setState(() => _queryController.text = code);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      duration: Duration(milliseconds: 1500),
                      content: Text('Contoh kode disalin ke editor'),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
        if (lesson.sandboxTables.isNotEmpty) ...[
          const SizedBox(height: 10),
          const _PanelTitle('Data latihan'),
          const SizedBox(height: 8),
          TableDataCard(table: lesson.sandboxTables.first),
        ],
      ],
    );
  }

  Widget _buildPracticePanel(LessonModel lesson, {required bool isOffline}) {
    final met = _metRequirements(lesson);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          borderColor: DesignTokens.primaryLight.withValues(alpha: 0.4),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.terminal_rounded,
                    size: 20,
                    color: DesignTokens.primaryLight,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Coba sendiri di editor',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                lesson.practicePrompt,
                style: const TextStyle(fontSize: 14, height: 1.45),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SqlCodeEditor(
          controller: _queryController,
          isOffline: isOffline,
          onRun: () => _runPracticeQuery(lesson),
          executionResult: _executionResult,
        ),
        const SizedBox(height: 20),

        // Checklist syarat penyelesaian lesson (Bagian 17 & AC-05)
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Syarat menyelesaikan lesson',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    '$met/3',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: DesignTokens.primaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const _RequirementRow(
                label: 'Membaca materi dan contoh kode',
                done: true,
              ),
              const SizedBox(height: 8),
              _RequirementRow(
                label: 'Menjalankan minimal 1 query di editor',
                done: lesson.hasExecutedQuery,
              ),
              const SizedBox(height: 8),
              _RequirementRow(
                label: 'Lulus kuis dengan skor ≥ 70%',
                done: lesson.hasPassedQuiz,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () => context.push('/lessons/${lesson.id}/quiz'),
                  icon: const Icon(Icons.quiz_outlined, size: 18),
                  label: Text(
                    lesson.hasPassedQuiz ? 'Ulangi kuis' : 'Kerjakan kuis',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _metRequirements(LessonModel lesson) {
    var met = 1; // membaca materi selalu dianggap terpenuhi (sama seperti sebelumnya)
    if (lesson.hasExecutedQuery) met++;
    if (lesson.hasPassedQuiz) met++;
    return met;
  }
}

// ---------------------------------------------------------------------------
// Bar penyelesaian (selalu terlihat di bawah)
// ---------------------------------------------------------------------------

class _CompletionBar extends StatelessWidget {
  final LessonModel lesson;
  final VoidCallback onComplete;

  const _CompletionBar({required this.lesson, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final completed = lesson.status == 'completed';
    var met = 1;
    if (lesson.hasExecutedQuery) met++;
    if (lesson.hasPassedQuiz) met++;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                completed
                    ? 'Lesson ini sudah selesai'
                    : '$met dari 3 syarat terpenuhi',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 8),
              PrimaryActionButton(
                label: completed ? 'Lesson selesai' : 'Selesaikan lesson',
                xpReward: completed ? null : lesson.xpReward,
                icon: Icons.check_circle_outline_rounded,
                onPressed: onComplete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Komponen kecil
// ---------------------------------------------------------------------------

class _PanelTitle extends StatelessWidget {
  final String text;
  const _PanelTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
    );
  }
}

class _CodeExample extends StatelessWidget {
  final String code;
  final VoidCallback onCopy;

  const _CodeExample({required this.code, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(14, 14, 4, 14),
              child: Text(
                code,
                softWrap: false,
                style: AppTheme.monoStyle(
                  fontSize: 13,
                  color: const Color(0xFF93C5FD),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Salin ke editor',
            onPressed: onCopy,
            icon: const Icon(
              Icons.content_copy_rounded,
              size: 18,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final String label;
  final bool done;

  const _RequirementRow({
    required this.label,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    final muted =
    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5);
    return Row(
      children: [
        Icon(
          done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          size: 20,
          color: done ? DesignTokens.successLight : muted,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: done ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}