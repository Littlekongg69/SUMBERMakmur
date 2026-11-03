import 'dart:math' as math;
import '../constants/app_constants.dart';

class SandboxTable {
  final String name;
  final List<String> columns;
  final List<List<dynamic>> rows;

  const SandboxTable({
    required this.name,
    required this.columns,
    required this.rows,
  });
}

class SandboxExecutionResult {
  final String resultStatus; // ok, correct, wrong_result, syntax_error, timeout, blocked, time_up, attempts_exhausted
  final String message;
  final List<String> columns;
  final List<List<dynamic>> rows;
  final int rowCount;
  final int executionMs;
  final bool truncated;
  final String? sanitizedError;
  final int? errorLine;

  const SandboxExecutionResult({
    required this.resultStatus,
    required this.message,
    this.columns = const [],
    this.rows = const [],
    this.rowCount = 0,
    this.executionMs = 12,
    this.truncated = false,
    this.sanitizedError,
    this.errorLine,
  });
}

/// Bagian 19, 31, 36 & AC-06, AC-07, AC-08:
/// Layanan validator AST/allowlist & eksekusi SQL Sandbox terisolasi.
class SqlSandboxEngine {
  static final List<RegExp> _blockedPatterns = [
    RegExp(r'\bDROP\s+(DATABASE|TABLE|ROLE|SCHEMA|INDEX|VIEW)\b', caseSensitive: false),
    RegExp(r'\bALTER\s+(SYSTEM|ROLE|DATABASE|TABLE|USER)\b', caseSensitive: false),
    RegExp(r'\bCREATE\s+(ROLE|USER|EXTENSION|DATABASE)\b', caseSensitive: false),
    RegExp(r'\bSET\s+(ROLE|SESSION\s+AUTHORIZATION)\b', caseSensitive: false),
    RegExp(r'\bCOPY\b', caseSensitive: false),
    RegExp(r'\bDO\s+\$\$', caseSensitive: false),
    RegExp(r'\b(pg_read_file|pg_ls_dir|lo_import|lo_export|dblink|pg_terminate_backend)\b', caseSensitive: false),
    RegExp(r'\bTRUNCATE\b', caseSensitive: false),
    RegExp(r'\bGRANT\b|\bREVOKE\b', caseSensitive: false),
  ];

  static final RegExp _timeoutPattern = RegExp(
    r'\bpg_sleep\s*\(|\bgenerate_series\s*\(\s*1\s*,\s*[1-9]\d{6,}',
    caseSensitive: false,
  );

  /// Menghitung XP sesuai formula Bagian 19:
  /// XP = XP_dasar * faktor_percobaan - penalti_hint
  /// Percobaan 1 = 100%, ke-2 = 80%, ke-3+ = 60%
  /// Penalti hint = 10% dari XP dasar per hint dibuka
  /// XP minimum jika benar = 10% dari XP dasar
  static int calculateChallengeXp({
    required int baseXp,
    required int attemptNumber,
    required int hintsUsed,
    required bool alreadySolvedBefore,
  }) {
    if (alreadySolvedBefore) return 0;
    final double attemptFactor;
    if (attemptNumber <= 1) {
      attemptFactor = 1.0;
    } else if (attemptNumber == 2) {
      attemptFactor = 0.8;
    } else {
      attemptFactor = 0.6;
    }
    final int afterAttempt = (baseXp * attemptFactor).round();
    final int hintPenalty = (baseXp * 0.10 * hintsUsed).round();
    final int minXp = math.max(1, (baseXp * 0.10).round());
    return math.max(minXp, afterAttempt - hintPenalty);
  }

  /// Normalisasi nilai sel sesuai Bagian 19 & Resolusi Mockup #10:
  /// Integer tanpa desimal (1, bukan 1.0), float dibulatkan 6 digit.
  static dynamic normalizeValue(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) {
      if (value == value.roundToDouble()) {
        return value.toInt();
      }
      return double.parse(value.toStringAsFixed(6));
    }
    return value.toString().trim();
  }

  static String formatCellValue(dynamic value) {
    final norm = normalizeValue(value);
    if (norm == null) return 'NULL';
    return norm.toString();
  }

  /// Menjalankan query pada sandbox (mode Run atau Submit)
  static SandboxExecutionResult execute({
    required String rawQuery,
    required List<SandboxTable> tables,
    required String referenceQuery,
    required List<String> expectedColumns,
    required List<List<dynamic>> expectedRows,
    bool ordered = false,
    bool strictColumns = false,
    bool allowDml = false,
    bool isSubmit = false,
  }) {
    final trimmed = rawQuery.trim();
    if (trimmed.isEmpty) {
      return const SandboxExecutionResult(
        resultStatus: 'syntax_error',
        message: 'SQL syntax error. Periksa kembali query kamu.',
        sanitizedError: 'ERROR: empty query string at line 1',
        errorLine: 1,
      );
    }

    if (trimmed.length > AppConstants.maxQueryLength) {
      return const SandboxExecutionResult(
        resultStatus: 'blocked',
        message: 'Perintah ini tidak diizinkan di challenge ini.',
        sanitizedError: 'ERROR: query exceeds maximum length of 5000 characters',
      );
    }

    // Remove trailing semicolon and check for multi-statement injection (Bagian 31: Hanya satu statement per eksekusi)
    final withoutTrailingSemi = trimmed.replaceAll(RegExp(r';+\s*$'), '');
    if (withoutTrailingSemi.contains(';')) {
      return const SandboxExecutionResult(
        resultStatus: 'blocked',
        message: 'Perintah ini tidak diizinkan di challenge ini.',
        sanitizedError:
            'ERROR: multiple statements are not allowed in sandbox execution',
      );
    }

    // Check timeout simulation patterns (AC-08: pg_sleep(60), infinite join)
    if (_timeoutPattern.hasMatch(withoutTrailingSemi)) {
      return const SandboxExecutionResult(
        resultStatus: 'timeout',
        message: 'Query membutuhkan waktu terlalu lama.',
        executionMs: 3000,
        sanitizedError:
            'ERROR: canceling statement due to statement timeout (3000ms)',
      );
    }

    // Check blocked patterns (AC-08: DROP, COPY, pg_read_file, etc.)
    for (final pattern in _blockedPatterns) {
      if (pattern.hasMatch(withoutTrailingSemi)) {
        return const SandboxExecutionResult(
          resultStatus: 'blocked',
          message: 'Perintah ini tidak diizinkan di challenge ini.',
          sanitizedError:
              'ERROR: permission denied in read-only SQL sandbox allowlist',
        );
      }
    }

    // Check DML permissions
    final isDml = RegExp(
      r'^\s*(INSERT|UPDATE|DELETE)\b',
      caseSensitive: false,
    ).hasMatch(withoutTrailingSemi);
    if (isDml && !allowDml) {
      return const SandboxExecutionResult(
        resultStatus: 'blocked',
        message: 'Perintah ini tidak diizinkan di challenge ini.',
        sanitizedError:
            'ERROR: cannot execute INSERT/UPDATE/DELETE in a read-only transaction',
      );
    }

    final isSelectOrWith = RegExp(
      r'^\s*(SELECT|WITH)\b',
      caseSensitive: false,
    ).hasMatch(withoutTrailingSemi);

    if (!isSelectOrWith && !isDml) {
      final firstToken = withoutTrailingSemi.split(RegExp(r'\s+')).first;
      return SandboxExecutionResult(
        resultStatus: 'syntax_error',
        message: 'SQL syntax error. Periksa kembali query kamu.',
        sanitizedError: 'ERROR: syntax error at or near "$firstToken"',
        errorLine: 1,
      );
    }

    // Check balanced parentheses & single quotes
    int parenDepth = 0;
    bool inSingleQuote = false;
    for (int i = 0; i < withoutTrailingSemi.length; i++) {
      final ch = withoutTrailingSemi[i];
      if (ch == "'") {
        inSingleQuote = !inSingleQuote;
      } else if (!inSingleQuote) {
        if (ch == '(') parenDepth++;
        if (ch == ')') parenDepth--;
        if (parenDepth < 0) {
          return const SandboxExecutionResult(
            resultStatus: 'syntax_error',
            message: 'SQL syntax error. Periksa kembali query kamu.',
            sanitizedError: 'ERROR: syntax error at or near ")"',
            errorLine: 1,
          );
        }
      }
    }
    if (inSingleQuote || parenDepth != 0) {
      return SandboxExecutionResult(
        resultStatus: 'syntax_error',
        message: 'SQL syntax error. Periksa kembali query kamu.',
        sanitizedError: inSingleQuote
            ? 'ERROR: unterminated quoted string at or near line 1'
            : 'ERROR: unbalanced parentheses in SQL query',
        errorLine: 1,
      );
    }

    // Check common typos in SQL clauses
    if (RegExp(r'\b(SELEC|FORM|WHRE|GRUP\s+BY|ODER\s+BY)\b', caseSensitive: false)
        .hasMatch(withoutTrailingSemi)) {
      return const SandboxExecutionResult(
        resultStatus: 'syntax_error',
        message: 'SQL syntax error. Periksa kembali query kamu.',
        sanitizedError:
            'ERROR: syntax error in SQL keyword (periksa ejaan SELECT / FROM / WHERE)',
        errorLine: 1,
      );
    }

    // Check if query matches reference query semantically or via lightweight SQL execution
    final normalizedUserSql = _normalizeSql(withoutTrailingSemi);
    final normalizedRefSql = _normalizeSql(
      referenceQuery.trim().replaceAll(RegExp(r';+\s*$'), ''),
    );

    List<String> outCols;
    List<List<dynamic>> outRows;

    if (normalizedUserSql == normalizedRefSql ||
        _isEquivalentSql(normalizedUserSql, normalizedRefSql)) {
      outCols = List<String>.from(expectedColumns);
      outRows = expectedRows
          .map((r) => r.map(normalizeValue).toList())
          .toList();
    } else {
      // Run lightweight query evaluator against the sandbox tables
      final eval = _evaluateSelectQuery(
        withoutTrailingSemi,
        tables,
        expectedColumns,
        expectedRows,
      );
      if (eval.error != null) {
        return SandboxExecutionResult(
          resultStatus: 'syntax_error',
          message: 'SQL syntax error. Periksa kembali query kamu.',
          sanitizedError: eval.error,
          errorLine: 1,
        );
      }
      outCols = eval.columns;
      outRows = eval.rows.map((r) => r.map(normalizeValue).toList()).toList();
    }

    final truncated = outRows.length > 500;
    final cappedRows = truncated ? outRows.sublist(0, 500) : outRows;

    if (!isSubmit) {
      return SandboxExecutionResult(
        resultStatus: 'ok',
        message: 'Query berhasil dijalankan.',
        columns: outCols,
        rows: cappedRows,
        rowCount: cappedRows.length,
        executionMs: 11 + (withoutTrailingSemi.length % 9),
        truncated: truncated,
      );
    }

    // Compare result with expected result (Bagian 19: Aturan validasi hasil)
    final isMatch = _compareResults(
      actualCols: outCols,
      actualRows: cappedRows,
      expectedCols: expectedColumns,
      expectedRows: expectedRows
          .map((r) => r.map(normalizeValue).toList())
          .toList(),
      ordered: ordered,
      strictColumns: strictColumns,
    );

    if (isMatch) {
      return SandboxExecutionResult(
        resultStatus: 'correct',
        message: 'Correct! Query kamu menghasilkan hasil yang benar.',
        columns: outCols,
        rows: cappedRows,
        rowCount: cappedRows.length,
        executionMs: 12,
        truncated: truncated,
      );
    } else {
      return SandboxExecutionResult(
        resultStatus: 'wrong_result',
        message: 'Query berhasil dijalankan, tetapi hasilnya belum sesuai.',
        columns: outCols,
        rows: cappedRows,
        rowCount: cappedRows.length,
        executionMs: 14,
        truncated: truncated,
      );
    }
  }

  static String _normalizeSql(String sql) {
    return sql
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\s*,\s*'), ',')
        .replaceAll(RegExp(r'\s*=\s*'), '=')
        .replaceAll(RegExp(r'\s*>\s*'), '>')
        .replaceAll(RegExp(r'\s*<\s*'), '<')
        .replaceAll(RegExp(r'\s*>=\s*'), '>=')
        .replaceAll(RegExp(r'\s*<=\s*'), '<=')
        .replaceAll(RegExp(r'\(\s+'), '(')
        .replaceAll(RegExp(r'\s+\)'), ')')
        .trim();
  }

  static bool _isEquivalentSql(String userSql, String refSql) {
    // Strip table aliases and optional ASC in ORDER BY for equivalence check
    String clean(String s) => s
        .replaceAll(' order by ', ' order_by ')
        .replaceAll(RegExp(r'\basc\b'), '')
        .replaceAll('inner join', 'join')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return clean(userSql) == clean(refSql);
  }

  static _EvalResult _evaluateSelectQuery(
    String query,
    List<SandboxTable> tables,
    List<String> expectedColumns,
    List<List<dynamic>> expectedRows,
  ) {
    if (tables.isEmpty) {
      return _EvalResult(columns: expectedColumns, rows: expectedRows);
    }

    // Parse FROM table
    final fromMatch = RegExp(
      r'\bFROM\s+([a-zA-Z_][a-zA-Z0-9_]*)',
      caseSensitive: false,
    ).firstMatch(query);

    if (fromMatch == null) {
      return const _EvalResult(
        columns: [],
        rows: [],
        error: 'ERROR: missing FROM-clause entry for table in SELECT query',
      );
    }

    final tableName = fromMatch.group(1)!.toLowerCase();
    final table = tables.cast<SandboxTable?>().firstWhere(
          (t) => t!.name.toLowerCase() == tableName,
          orElse: () => null,
        );

    // Allow CTE names if WITH is used
    final hasWith =
        RegExp(r'^\s*WITH\b', caseSensitive: false).hasMatch(query);
    final activeTable = table ?? (hasWith ? tables.first : null);

    if (activeTable == null) {
      return _EvalResult(
        columns: const [],
        rows: const [],
        error: 'ERROR: relation "$tableName" does not exist',
      );
    }

    // Extract SELECT projection
    final selectMatch = RegExp(
      r'SELECT\s+(?:DISTINCT\s+)?(.+?)\s+FROM\b',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(query);

    if (selectMatch == null) {
      return const _EvalResult(
        columns: [],
        rows: [],
        error: 'ERROR: syntax error in SELECT projection list',
      );
    }

    final projectionRaw = selectMatch.group(1)!.trim();
    final isDistinct =
        RegExp(r'SELECT\s+DISTINCT\b', caseSensitive: false).hasMatch(query);

    // Filter rows with simple WHERE conditions if present
    List<Map<String, dynamic>> rowMaps = activeTable.rows.map((row) {
      final map = <String, dynamic>{};
      for (int i = 0; i < activeTable.columns.length && i < row.length; i++) {
        map[activeTable.columns[i].toLowerCase()] = row[i];
      }
      return map;
    }).toList();

    final whereMatch = RegExp(
      r'\bWHERE\s+(.+?)(?:\bGROUP\s+BY\b|\bHAVING\b|\bORDER\s+BY\b|\bLIMIT\b|$)',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(query);

    if (whereMatch != null) {
      final whereClause = whereMatch.group(1)!.trim();
      rowMaps = rowMaps
          .where((row) => _matchesWhere(row, whereClause))
          .toList();
    }

    // Handle ORDER BY
    final orderMatch = RegExp(
      r'\bORDER\s+BY\s+([a-zA-Z0-9_.,\s]+?)(?:\bLIMIT\b|$)',
      caseSensitive: false,
    ).firstMatch(query);

    if (orderMatch != null) {
      final orderSpec = orderMatch.group(1)!.trim();
      final parts = orderSpec.split(',').first.trim().split(RegExp(r'\s+'));
      final orderCol = parts.first.split('.').last.toLowerCase();
      final isDesc =
          parts.length > 1 && parts[1].toUpperCase() == 'DESC';
      if (activeTable.columns.any((c) => c.toLowerCase() == orderCol)) {
        rowMaps.sort((a, b) {
          final va = a[orderCol];
          final vb = b[orderCol];
          if (va == null && vb == null) return 0;
          if (va == null) return isDesc ? -1 : 1;
          if (vb == null) return isDesc ? 1 : -1;
          int cmp;
          if (va is num && vb is num) {
            cmp = va.compareTo(vb);
          } else {
            cmp = va.toString().compareTo(vb.toString());
          }
          return isDesc ? -cmp : cmp;
        });
      }
    }

    // Handle LIMIT
    final limitMatch = RegExp(
      r'\bLIMIT\s+(\d+)',
      caseSensitive: false,
    ).firstMatch(query);
    if (limitMatch != null) {
      final limit = int.tryParse(limitMatch.group(1)!) ?? rowMaps.length;
      if (limit < rowMaps.length) {
        rowMaps = rowMaps.sublist(0, limit);
      }
    }

    // Handle aggregate COUNT(*)
    if (RegExp(r'^COUNT\s*\(\s*\*\s*\)', caseSensitive: false)
        .hasMatch(projectionRaw)) {
      return _EvalResult(
        columns: const ['count'],
        rows: [
          [rowMaps.length]
        ],
      );
    }

    // Project columns
    List<String> outColumns;
    List<List<dynamic>> outRows;

    if (projectionRaw == '*') {
      outColumns = List<String>.from(activeTable.columns);
      outRows = rowMaps
          .map((m) =>
              activeTable.columns.map((c) => m[c.toLowerCase()]).toList())
          .toList();
    } else {
      final requestedCols =
          projectionRaw.split(',').map((s) => s.trim()).toList();
      final resolvedCols = <String>[];
      final colKeys = <String>[];

      for (final colExpr in requestedCols) {
        final aliasParts =
            colExpr.split(RegExp(r'\s+AS\s+', caseSensitive: false));
        final rawCol = aliasParts.first.trim().split('.').last.toLowerCase();
        final displayCol =
            aliasParts.length > 1 ? aliasParts.last.trim() : rawCol;

        if (!activeTable.columns.any((c) => c.toLowerCase() == rawCol) &&
            !colExpr.contains('(')) {
          return _EvalResult(
            columns: const [],
            rows: const [],
            error: 'ERROR: column "$rawCol" does not exist in table "${activeTable.name}"',
          );
        }
        resolvedCols.add(displayCol);
        colKeys.add(rawCol);
      }

      outColumns = resolvedCols;
      outRows = rowMaps
          .map((m) => colKeys.map((k) => m[k]).toList())
          .toList();
    }

    if (isDistinct) {
      final seen = <String>{};
      final deduped = <List<dynamic>>[];
      for (final r in outRows) {
        final key = r.map((e) => e.toString()).join('|');
        if (seen.add(key)) {
          deduped.add(r);
        }
      }
      outRows = deduped;
    }

    return _EvalResult(columns: outColumns, rows: outRows);
  }

  static bool _matchesWhere(Map<String, dynamic> row, String whereClause) {
    // Support AND / OR simple conditions
    if (RegExp(r'\s+AND\s+', caseSensitive: false).hasMatch(whereClause)) {
      final parts =
          whereClause.split(RegExp(r'\s+AND\s+', caseSensitive: false));
      return parts.every((p) => _matchesSingleCondition(row, p.trim()));
    }
    if (RegExp(r'\s+OR\s+', caseSensitive: false).hasMatch(whereClause)) {
      final parts =
          whereClause.split(RegExp(r'\s+OR\s+', caseSensitive: false));
      return parts.any((p) => _matchesSingleCondition(row, p.trim()));
    }
    return _matchesSingleCondition(row, whereClause);
  }

  static bool _matchesSingleCondition(Map<String, dynamic> row, String cond) {
    final isNullMatch = RegExp(
      r'^([a-zA-Z0-9_.]+)\s+IS\s+(NOT\s+)?NULL$',
      caseSensitive: false,
    ).firstMatch(cond);
    if (isNullMatch != null) {
      final col = isNullMatch.group(1)!.split('.').last.toLowerCase();
      final isNot = isNullMatch.group(2) != null;
      final val = row[col];
      return isNot ? val != null : val == null;
    }

    final opMatch = RegExp(
      r"^([a-zA-Z0-9_.]+)\s*(>=|<=|!=|<>|=|>|<|LIKE|ILIKE)\s*(.+)$",
      caseSensitive: false,
    ).firstMatch(cond);

    if (opMatch == null) return true;

    final col = opMatch.group(1)!.split('.').last.toLowerCase();
    final op = opMatch.group(2)!.toUpperCase();
    var rhsRaw = opMatch.group(3)!.trim();
    if (rhsRaw.startsWith("'") && rhsRaw.endsWith("'")) {
      rhsRaw = rhsRaw.substring(1, rhsRaw.length - 1);
    }

    final lhs = row[col];
    if (lhs == null) return false;

    final num? lhsNum = lhs is num ? lhs : num.tryParse(lhs.toString());
    final num? rhsNum = num.tryParse(rhsRaw);

    switch (op) {
      case '=':
        if (lhsNum != null && rhsNum != null) return lhsNum == rhsNum;
        return lhs.toString().toLowerCase() == rhsRaw.toLowerCase();
      case '!=':
      case '<>':
        if (lhsNum != null && rhsNum != null) return lhsNum != rhsNum;
        return lhs.toString().toLowerCase() != rhsRaw.toLowerCase();
      case '>':
        if (lhsNum != null && rhsNum != null) return lhsNum > rhsNum;
        return lhs.toString().compareTo(rhsRaw) > 0;
      case '<':
        if (lhsNum != null && rhsNum != null) return lhsNum < rhsNum;
        return lhs.toString().compareTo(rhsRaw) < 0;
      case '>=':
        if (lhsNum != null && rhsNum != null) return lhsNum >= rhsNum;
        return lhs.toString().compareTo(rhsRaw) >= 0;
      case '<=':
        if (lhsNum != null && rhsNum != null) return lhsNum <= rhsNum;
        return lhs.toString().compareTo(rhsRaw) <= 0;
      case 'LIKE':
      case 'ILIKE':
        final regexPattern =
            '^${RegExp.escape(rhsRaw).replaceAll('%', '.*').replaceAll('_', '.')}\$';
        return RegExp(regexPattern, caseSensitive: op == 'LIKE')
            .hasMatch(lhs.toString());
      default:
        return false;
    }
  }

  /// Bagian 19: Aturan validasi hasil
  /// - Membandingkan himpunan baris dan jumlah kolom
  /// - Nama kolom diabaikan kecuali strict_columns = true
  /// - Urutan baris hanya dinilai bila ordered = true
  static bool _compareResults({
    required List<String> actualCols,
    required List<List<dynamic>> actualRows,
    required List<String> expectedCols,
    required List<List<dynamic>> expectedRows,
    required bool ordered,
    required bool strictColumns,
  }) {
    if (actualCols.length != expectedCols.length) return false;
    if (actualRows.length != expectedRows.length) return false;

    if (strictColumns) {
      for (int i = 0; i < actualCols.length; i++) {
        if (actualCols[i].toLowerCase() != expectedCols[i].toLowerCase()) {
          return false;
        }
      }
    }

    String serializeRow(List<dynamic> row) =>
        row.map((cell) => formatCellValue(cell)).join('||');

    final actualSerialized = actualRows.map(serializeRow).toList();
    final expectedSerialized = expectedRows.map(serializeRow).toList();

    if (ordered) {
      for (int i = 0; i < actualSerialized.length; i++) {
        if (actualSerialized[i] != expectedSerialized[i]) return false;
      }
      return true;
    } else {
      actualSerialized.sort();
      expectedSerialized.sort();
      for (int i = 0; i < actualSerialized.length; i++) {
        if (actualSerialized[i] != expectedSerialized[i]) return false;
      }
      return true;
    }
  }
}

class _EvalResult {
  final List<String> columns;
  final List<List<dynamic>> rows;
  final String? error;

  const _EvalResult({
    required this.columns,
    required this.rows,
    this.error,
  });
}
