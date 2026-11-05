import 'package:flutter/material.dart';
import 'package:sqlquest/core/theme/design_tokens.dart';

import '../../domain/entities/challenge_difficulty.dart';

/// Pemetaan warna untuk tiap tingkat kesulitan (urusan tampilan,
/// jadi sengaja tidak berada di layer domain).
extension ChallengeDifficultyStyle on ChallengeDifficulty {
  Color get color => switch (this) {
    ChallengeDifficulty.easy => DesignTokens.successLight,
    ChallengeDifficulty.medium => DesignTokens.primaryLight,
    ChallengeDifficulty.hard => DesignTokens.xpRewardLight,
    ChallengeDifficulty.expert => DesignTokens.errorLight,
    ChallengeDifficulty.all => DesignTokens.primaryLight,
  };
}
