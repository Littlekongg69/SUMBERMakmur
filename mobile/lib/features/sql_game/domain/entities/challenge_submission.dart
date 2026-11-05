import 'package:sqlquest/core/utils/sql_sandbox_engine.dart';

/// Hasil dari pengiriman jawaban (submit) sebuah challenge.
class ChallengeSubmission {
  const ChallengeSubmission({
    required this.execution,
    required this.xpAwarded,
    required this.attemptsRemaining,
    required this.leveledUp,
  });

  final SandboxExecutionResult execution;
  final int xpAwarded;
  final int attemptsRemaining;
  final bool leveledUp;
}
