import 'package:flutter/material.dart';

import '../../domain/entities/challenge_difficulty.dart';

/// Baris chip horizontal untuk memfilter challenge per tingkat kesulitan.
class DifficultyFilterBar extends StatelessWidget {
  const DifficultyFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final ChallengeDifficulty selected;
  final ValueChanged<ChallengeDifficulty> onSelected;

  static const List<ChallengeDifficulty> _options = ChallengeDifficulty.values;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final difficulty = _options[index];
          return ChoiceChip(
            selected: difficulty == selected,
            label: Text(difficulty.displayLabel),
            onSelected: (_) => onSelected(difficulty),
          );
        },
      ),
    );
  }
}
