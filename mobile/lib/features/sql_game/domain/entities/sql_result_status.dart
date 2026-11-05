import 'package:sqlquest/core/utils/sql_sandbox_engine.dart';

/// Nilai `resultStatus` yang dikembalikan sandbox SQL.
///
/// Dipusatkan di sini agar tidak ada string literal yang tersebar di UI.
abstract final class SqlResultStatus {
  static const String ok = 'ok';
  static const String correct = 'correct';
  static const String wrongResult = 'wrong_result';
  static const String syntaxError = 'syntax_error';
  static const String timeout = 'timeout';
  static const String blocked = 'blocked';
  static const String timeUp = 'time_up';
  static const String attemptsExhausted = 'attempts_exhausted';
}

/// Hasil eksekusi siap pakai yang dibuat oleh sisi aplikasi (bukan sandbox).
abstract final class SqlGameResults {
  static const SandboxExecutionResult timeUp = SandboxExecutionResult(
    resultStatus: SqlResultStatus.timeUp,
    message: 'Waktu habis. Coba lagi untuk skor terbaik.',
  );
}

extension SandboxExecutionResultX on SandboxExecutionResult {
  bool get isCorrect => resultStatus == SqlResultStatus.correct;
  bool get isAttemptsExhausted =>
      resultStatus == SqlResultStatus.attemptsExhausted;
}
