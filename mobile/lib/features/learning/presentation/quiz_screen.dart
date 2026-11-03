import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/models/app_state_provider.dart';
import '../../../shared/widgets/sqlquest_widgets.dart';

/// Bagian 17 & 33:
/// Kuis Lesson: Satu pertanyaan per layar di mobile, umpan balik instan setelah jawab,
/// progress soal, skor kelulusan >= 70%, maks 3 percobaan untuk XP.
///
/// Perubahan desain:
/// - Pilihan jawaban memakai badge huruf A/B/C/D, berubah jadi centang/silang setelah diperiksa.
/// - Pertanyaan, pilihan, dan penjelasan ada dalam satu area scroll, tombol aksi tetap di bawah.
/// - Layar hasil menampilkan skor dalam lingkaran progress dan menawarkan "Baca ulang lesson".
/// - Saat kuis diulang, skor dan XP dari percobaan sebelumnya ikut di-reset.
class QuizScreen extends ConsumerStatefulWidget {
  final String lessonId;

  const QuizScreen({
    super.key,
    required this.lessonId,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentIndex = 0;
  int? _selectedOption;
  bool _hasCheckedCurrent = false;
  int _correctCount = 0;
  bool _finished = false;
  int _awardedXp = 0;
  int _finalScore = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final lesson = state.findLessonById(widget.lessonId);

    if (lesson == null || lesson.quizQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kuis lesson')),
        body: const Center(child: Text('Tidak ada kuis untuk lesson ini.')),
      );
    }

    final questions = lesson.quizQuestions;

    if (_finished) {
      return _buildResult(questions.length);
    }

    final currentQ = questions[_currentIndex];
    final isLast = _currentIndex + 1 == questions.length;
    final isCorrectAnswer = _selectedOption == currentQ.correctOptionIndex;

    return Scaffold(
      appBar: AppBar(title: Text('Kuis: ${lesson.title}')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              XpProgressBar(
                progress: (_currentIndex + 1) / questions.length,
                leftLabel:
                'Pertanyaan ${_currentIndex + 1} dari ${questions.length}',
                rightLabel:
                'Percobaan ke-${(lesson.quizAttempts + 1).clamp(1, 99)}',
                color: DesignTokens.primaryLight,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      currentQ.question,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    for (var idx = 0; idx < currentQ.options.length; idx++) ...[
                      _OptionCard(
                        letter: String.fromCharCode(65 + idx),
                        text: currentQ.options[idx],
                        selected: _selectedOption == idx,
                        checked: _hasCheckedCurrent,
                        isCorrectOption: idx == currentQ.correctOptionIndex,
                        onTap: _hasCheckedCurrent
                            ? null
                            : () => setState(() => _selectedOption = idx),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (_hasCheckedCurrent) ...[
                      const SizedBox(height: 6),
                      _FeedbackCard(
                        correct: isCorrectAnswer,
                        explanation: currentQ.explanation,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              PrimaryActionButton(
                label: !_hasCheckedCurrent
                    ? 'Periksa jawaban'
                    : (isLast ? 'Selesaikan kuis' : 'Soal berikutnya'),
                onPressed: _selectedOption == null
                    ? null
                    : () {
                  if (!_hasCheckedCurrent) {
                    setState(() {
                      _hasCheckedCurrent = true;
                      if (_selectedOption ==
                          currentQ.correctOptionIndex) {
                        _correctCount++;
                      }
                    });
                  } else if (!isLast) {
                    setState(() {
                      _currentIndex++;
                      _selectedOption = null;
                      _hasCheckedCurrent = false;
                    });
                  } else {
                    final score =
                    ((_correctCount / questions.length) * 100)
                        .round();
                    final res = ref
                        .read(appStateProvider.notifier)
                        .submitLessonQuiz(
                      lessonId: lesson.id,
                      scorePercent: score,
                    );
                    setState(() {
                      _finished = true;
                      _finalScore = res.scorePercent;
                      _awardedXp = res.xpAwarded;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult(int totalQuestions) {
    final passed = _finalScore >= 70;
    final color = passed ? DesignTokens.successLight : DesignTokens.errorLight;
    final muted =
    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65);

    return Scaffold(
      appBar: AppBar(title: const Text('Hasil kuis')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 132,
                  height: 132,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: (_finalScore / 100).clamp(0.0, 1.0),
                        strokeWidth: 10,
                        strokeCap: StrokeCap.round,
                        color: color,
                        backgroundColor: color.withValues(alpha: 0.15),
                      ),
                      Center(
                        child: Text(
                          '$_finalScore%',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  passed ? 'Kuis lulus!' : 'Belum lulus',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$_correctCount dari $totalQuestions soal benar',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!passed) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Skor minimal untuk lulus adalah 70%.',
                    style: TextStyle(fontSize: 13.5, color: muted),
                  ),
                ],
                if (_awardedXp > 0) ...[
                  const SizedBox(height: 14),
                  StatusPill(
                    label: '+$_awardedXp XP kuis diterima',
                    color: DesignTokens.xpRewardLight,
                  ),
                ],
                const SizedBox(height: 32),
                PrimaryActionButton(
                  label: passed ? 'Kembali ke lesson' : 'Ulangi kuis',
                  onPressed: () {
                    if (passed) {
                      context.pop();
                    } else {
                      setState(() {
                        _currentIndex = 0;
                        _selectedOption = null;
                        _hasCheckedCurrent = false;
                        _correctCount = 0;
                        _finalScore = 0;
                        _awardedXp = 0;
                        _finished = false;
                      });
                    }
                  },
                ),
                if (!passed) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: () => context.pop(),
                      child: const Text('Baca ulang lesson'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pilihan jawaban
// ---------------------------------------------------------------------------

class _OptionCard extends StatelessWidget {
  final String letter;
  final String text;
  final bool selected;
  final bool checked;
  final bool isCorrectOption;
  final VoidCallback? onTap;

  const _OptionCard({
    required this.letter,
    required this.text,
    required this.selected,
    required this.checked,
    required this.isCorrectOption,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final muted =
    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);

    Color? borderColor;
    Color badgeBg = muted.withValues(alpha: 0.12);
    Color badgeFg = muted;
    IconData? badgeIcon;

    if (checked) {
      if (isCorrectOption) {
        borderColor = DesignTokens.successLight;
        badgeBg = DesignTokens.successLight;
        badgeFg = Colors.white;
        badgeIcon = Icons.check_rounded;
      } else if (selected) {
        borderColor = DesignTokens.errorLight;
        badgeBg = DesignTokens.errorLight;
        badgeFg = Colors.white;
        badgeIcon = Icons.close_rounded;
      }
    } else if (selected) {
      borderColor = DesignTokens.primaryLight;
      badgeBg = DesignTokens.primaryLight;
      badgeFg = Colors.white;
    }

    return Semantics(
      button: onTap != null,
      selected: selected,
      child: AppCard(
        onTap: onTap,
        borderColor: borderColor,
        borderWidth: borderColor != null ? 2 : 1,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: badgeBg, shape: BoxShape.circle),
              child: badgeIcon != null
                  ? Icon(badgeIcon, size: 18, color: badgeFg)
                  : Text(
                letter,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: badgeFg,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.3,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Umpan balik setelah memeriksa jawaban
// ---------------------------------------------------------------------------

class _FeedbackCard extends StatelessWidget {
  final bool correct;
  final String explanation;

  const _FeedbackCard({required this.correct, required this.explanation});

  @override
  Widget build(BuildContext context) {
    final color = correct ? DesignTokens.successLight : DesignTokens.errorLight;

    return AppCard(
      borderColor: color,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            correct ? Icons.check_circle_rounded : Icons.info_rounded,
            color: color,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  correct ? 'Jawaban benar!' : 'Kurang tepat',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  explanation,
                  style: const TextStyle(fontSize: 14, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}