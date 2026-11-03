import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/utils/sql_sandbox_engine.dart';
import 'sqlquest_widgets.dart';

/// MOB-06 & Bagian 33:
/// Editor SQL monospace, penomoran baris, syntax highlighting, toolbar kata kunci SQL,
/// tombol Run dan Submit, serta tabel hasil yang dapat di-scroll horizontal.
class SqlHighlightingController extends TextEditingController {
  SqlHighlightingController({super.text});

  static final RegExp _keywordRegex = RegExp(
    r'\b(SELECT|FROM|WHERE|AND|OR|NOT|ORDER\s+BY|GROUP\s+BY|HAVING|LIMIT|JOIN|INNER|LEFT|RIGHT|ON|AS|DISTINCT|COUNT|SUM|AVG|MIN|MAX|WITH|INSERT|INTO|VALUES|UPDATE|SET|DELETE|ASC|DESC|LIKE|ILIKE|IS|NULL)\b',
    caseSensitive: false,
  );

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final children = <TextSpan>[];
    final raw = text;
    int lastEnd = 0;

    for (final match in _keywordRegex.allMatches(raw)) {
      if (match.start > lastEnd) {
        children.add(
          TextSpan(text: raw.substring(lastEnd, match.start), style: style),
        );
      }
      children.add(
        TextSpan(
          text: raw.substring(match.start, match.end),
          style: style?.copyWith(
            color: const Color(0xFF60A5FA),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      lastEnd = match.end;
    }

    if (lastEnd < raw.length) {
      children.add(TextSpan(text: raw.substring(lastEnd), style: style));
    }

    return TextSpan(style: style, children: children);
  }
}

class SqlCodeEditor extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onRun;
  final VoidCallback? onSubmit;
  final String submitLabel;
  final int? submitXpReward;
  final bool isOffline;
  final SandboxExecutionResult? executionResult;

  const SqlCodeEditor({
    super.key,
    required this.controller,
    required this.onRun,
    this.onSubmit,
    this.submitLabel = 'Submit Query',
    this.submitXpReward,
    this.isOffline = false,
    this.executionResult,
  });

  static const List<String> _sqlKeywords = [
    'SELECT ',
    '* ',
    'FROM ',
    'WHERE ',
    'AND ',
    'ORDER BY ',
    'DESC',
    'ASC',
    'LIMIT ',
    'COUNT(*)',
    'DISTINCT ',
    'LIKE ',
    '=',
    '>',
    '<',
    "'",
    ';',
  ];

  void _insertSnippet(String snippet) {
    final text = controller.text;
    final selection = controller.selection;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final newText = text.replaceRange(start, end, snippet);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + snippet.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final linesCount =
        controller.text.isEmpty ? 1 : controller.text.split('\n').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SQL Editor Box (Monospace + Line Numbers)
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF334155)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Editor Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.terminal_rounded,
                          size: 16,
                          color: Color(0xFF60A5FA),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'PostgreSQL Sandbox Editor',
                          style: AppTheme.monoStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE2E8F0),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => controller.clear(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Line Numbers + TextField
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller,
                      builder: (context, value, _) {
                        final count = value.text.isEmpty
                            ? 1
                            : value.text.split('\n').length.clamp(1, 20);
                        return Padding(
                          padding: const EdgeInsets.only(right: 10, top: 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(
                              count < linesCount ? linesCount : count,
                              (i) => Text(
                                '${i + 1}',
                                style: AppTheme.monoStyle(
                                  fontSize: 13,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        maxLines: 5,
                        minLines: 3,
                        style: AppTheme.monoStyle(
                          fontSize: 13.5,
                          color: const Color(0xFFF8FAFC),
                        ),
                        decoration: InputDecoration(
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText: 'SELECT * FROM users WHERE ...;',
                          hintStyle: AppTheme.monoStyle(
                            fontSize: 13,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Toolbar Kata Kunci SQL (MOB-06)
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(13)),
                ),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sqlKeywords.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final kw = _sqlKeywords[index];
                    return Center(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () => _insertSnippet(kw),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF334155),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            kw.trim(),
                            style: AppTheme.monoStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF93C5FD),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Run & Submit Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isOffline ? null : onRun,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Run Query'),
              ),
            ),
            if (onSubmit != null) ...[
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: PrimaryActionButton(
                  label: submitLabel,
                  xpReward: submitXpReward,
                  icon: Icons.send_rounded,
                  onPressed: isOffline ? null : onSubmit,
                ),
              ),
            ],
          ],
        ),

        if (isOffline) ...[
          const SizedBox(height: 8),
          const Text(
            'Mode offline: Eksekusi query dan submit membutuhkan koneksi internet (MOB-04).',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFFD97706),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],

        if (executionResult != null) ...[
          const SizedBox(height: 14),
          SqlExecutionResultView(result: executionResult!),
        ],
      ],
    );
  }
}

/// Bagian 36: Tampilan status hasil SQL Game (correct, wrong_result, syntax_error, timeout, blocked, attempts_exhausted)
class SqlExecutionResultView extends StatelessWidget {
  final SandboxExecutionResult result;

  const SqlExecutionResultView({
    super.key,
    required this.result,
  });

  Color get _statusColor {
    switch (result.resultStatus) {
      case 'correct':
      case 'ok':
        return DesignTokens.successLight;
      case 'wrong_result':
        return DesignTokens.xpRewardLight;
      case 'timeout':
      case 'time_up':
        return const Color(0xFFEA580C);
      case 'syntax_error':
      case 'blocked':
      case 'attempts_exhausted':
      default:
        return DesignTokens.errorLight;
    }
  }

  IconData get _statusIcon {
    switch (result.resultStatus) {
      case 'correct':
      case 'ok':
        return Icons.check_circle_rounded;
      case 'wrong_result':
        return Icons.warning_amber_rounded;
      case 'timeout':
      case 'time_up':
        return Icons.timer_off_rounded;
      case 'blocked':
        return Icons.shield_outlined;
      default:
        return Icons.error_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      borderColor: color.withValues(alpha: 0.6),
      borderWidth: 1.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_statusIcon, color: color, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.message,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              Text(
                '${result.executionMs} ms',
                style: AppTheme.monoStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          if (result.sanitizedError != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                result.errorLine != null
                    ? 'Line ${result.errorLine}: ${result.sanitizedError}'
                    : result.sanitizedError!,
                style: AppTheme.monoStyle(
                  fontSize: 12,
                  color: color,
                ),
              ),
            ),
          ],
          if (result.columns.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hasil Query (${result.rowCount} baris)',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (result.truncated)
                  const StatusPill(
                    label: 'Truncated (maks 500 baris)',
                    color: DesignTokens.xpRewardLight,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 34,
                dataRowMinHeight: 30,
                dataRowMaxHeight: 34,
                columnSpacing: 18,
                horizontalMargin: 10,
                headingRowColor: WidgetStatePropertyAll(
                  isDark ? const Color(0xFF252F3F) : const Color(0xFFF1F5F9),
                ),
                columns: result.columns
                    .map(
                      (col) => DataColumn(
                        label: Text(
                          col,
                          style: AppTheme.monoStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                rows: result.rows
                    .map(
                      (row) => DataRow(
                        cells: row
                            .map(
                              (cell) => DataCell(
                                Text(
                                  SqlSandboxEngine.formatCellValue(cell),
                                  style: AppTheme.monoStyle(fontSize: 12),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

