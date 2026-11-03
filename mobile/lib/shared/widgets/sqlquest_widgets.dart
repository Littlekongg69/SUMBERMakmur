import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/utils/sql_sandbox_engine.dart';
import '../models/app_models.dart';

/// AppCard sesuai PRD Bagian 19 & 33
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double borderWidth;
  final Gradient? gradient;
  final Color? backgroundColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderColor,
    this.borderWidth = 1.0,
    this.gradient,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBorder =
        isDark ? DesignTokens.borderDark : DesignTokens.borderLight;
    final defaultBg = backgroundColor ??
        (isDark ? DesignTokens.surfaceDark : Colors.white);

    final content = Container(
      padding: padding ?? const EdgeInsets.all(DesignTokens.cardPadding),
      decoration: BoxDecoration(
        color: gradient == null ? defaultBg : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
        border: Border.all(
          color: borderColor ?? defaultBorder,
          width: borderWidth,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

/// XpProgressBar sesuai PRD Bagian 19 & 33
class XpProgressBar extends StatelessWidget {
  final double progress;
  final String? leftLabel;
  final String? rightLabel;
  final Color? color;
  final Color? trackColor;
  final double height;

  const XpProgressBar({
    super.key,
    required this.progress,
    this.leftLabel,
    this.rightLabel,
    this.color,
    this.trackColor,
    this.height = 10,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final activeColor = color ?? DesignTokens.xpRewardLight;
    final bgTrack = trackColor ?? activeColor.withValues(alpha: 0.18);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leftLabel != null || rightLabel != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (leftLabel != null)
                Text(
                  leftLabel!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (rightLabel != null)
                Text(
                  rightLabel!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(DesignTokens.pillRadius),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 0, end: clamped),
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                minHeight: height,
                backgroundColor: bgTrack,
                valueColor: AlwaysStoppedAnimation<Color>(activeColor),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// StreakChip sesuai PRD Bagian 14 & 19 (ikon api + hari)
class StreakChip extends StatelessWidget {
  final int streakDays;
  final bool inverted;

  const StreakChip({
    super.key,
    required this.streakDays,
    this.inverted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: inverted
            ? Colors.white.withValues(alpha: 0.18)
            : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(DesignTokens.pillRadius),
        border: Border.all(
          color: inverted
              ? Colors.white.withValues(alpha: 0.35)
              : const Color(0xFFFDE68A),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            size: 18,
            color: Color(0xFFF59E0B),
          ),
          const SizedBox(width: 4),
          Text(
            '$streakDays Hari',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: inverted ? Colors.white : const Color(0xFFB45309),
            ),
          ),
        ],
      ),
    );
  }
}

/// StatTile sesuai PRD Bagian 19
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? accentColor;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? DesignTokens.primaryLight;
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// WeekStreakRow sesuai PRD Bagian 14: 7 lingkaran Sen-Min + current_streak
class WeekStreakRow extends StatelessWidget {
  final List<bool> activeDays;
  final int currentStreak;

  const WeekStreakRow({
    super.key,
    required this.activeDays,
    required this.currentStreak,
  });

  static const List<String> _dayLabels = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Minggu Ini',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: DesignTokens.successLight.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(DesignTokens.pillRadius),
                ),
                child: Text(
                  '$currentStreak hari berturut-turut',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: DesignTokens.successLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isActive =
                  index < activeDays.length && activeDays[index];
              return Column(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? DesignTokens.successLight
                          : Colors.transparent,
                      border: Border.all(
                        color: isActive
                            ? DesignTokens.successLight
                            : Colors.grey.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: isActive
                        ? const Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _dayLabels[index],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// StatusPill sesuai PRD Bagian 19
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const StatusPill({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(DesignTokens.pillRadius),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// ModuleCard sesuai PRD Bagian 14 & 19 (varian: selesai, aktif, terkunci)
class ModuleCard extends StatelessWidget {
  final ModuleModel module;
  final VoidCallback onTap;

  const ModuleCard({
    super.key,
    required this.module,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = module.status;
    final isCompleted = status == 'completed';
    final isInProgress = status == 'in_progress';
    final isLocked = status == 'locked';

    final statusColor = isCompleted
        ? DesignTokens.successLight
        : isInProgress
            ? DesignTokens.primaryLight
            : Colors.grey;

    final statusLabel = isCompleted
        ? 'Selesai'
        : isInProgress
            ? 'Sedang Dikerjakan'
            : isLocked
                ? 'Terkunci'
                : 'Tersedia';

    return AppCard(
      onTap: onTap,
      borderColor: isInProgress ? DesignTokens.primaryLight : null,
      borderWidth: isInProgress ? 2.0 : 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_circle_rounded
                      : isLocked
                          ? Icons.lock_rounded
                          : Icons.storage_rounded,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          module.worldLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                        StatusPill(label: statusLabel, color: statusColor),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      module.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isCompleted
                    ? Icons.check_circle_rounded
                    : isLocked
                        ? Icons.lock_outline_rounded
                        : Icons.chevron_right_rounded,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            module.description,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 15,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.55),
              ),
              const SizedBox(width: 4),
              Text(
                '${module.estimatedMinutes} menit · ${module.lessons.length} lesson',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          if (isInProgress) ...[
            const SizedBox(height: 12),
            XpProgressBar(
              progress: module.progressPercent / 100.0,
              leftLabel: 'Progress Modul',
              rightLabel: '${module.progressPercent}%',
              color: DesignTokens.primaryLight,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('Lanjutkan Belajar'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// MissionBanner sesuai PRD Bagian 14 & 19 (Tantangan Harian + badge XP)
class MissionBanner extends StatelessWidget {
  final DailyMissionModel mission;
  final VoidCallback onTap;

  const MissionBanner({
    super.key,
    required this.mission,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = mission.status == 'completed';
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: Color(0xFFD97706),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tantangan Harian',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD97706),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mission.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(DesignTokens.pillRadius),
                ),
                child: Text(
                  '+${mission.xpReward} XP',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          XpProgressBar(
            progress: mission.progressRatio,
            leftLabel: isDone ? 'Selesai!' : 'Progress Misi',
            rightLabel: '${mission.progress} / ${mission.target}',
            color:
                isDone ? DesignTokens.successLight : DesignTokens.xpRewardLight,
          ),
        ],
      ),
    );
  }
}

/// HeartsIndicator sesuai PRD Bagian 14 (maks 5 hati ditampilkan, berkurang 1 per wrong_result)
class HeartsIndicator extends StatelessWidget {
  final int remainingHearts;
  final int maxHearts;

  const HeartsIndicator({
    super.key,
    required this.remainingHearts,
    this.maxHearts = 5,
  });

  @override
  Widget build(BuildContext context) {
    final total = maxHearts.clamp(1, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (index) {
        final filled = index < remainingHearts;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: Icon(
            filled ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            size: 18,
            color: filled ? const Color(0xFFEF4444) : Colors.grey.shade400,
          ),
        );
      }),
    );
  }
}

/// TableDataCard sesuai PRD Bagian 14: Nama tabel, jumlah baris, kolom & baris contoh, scroll horizontal, integer tanpa desimal
class TableDataCard extends StatelessWidget {
  final SandboxTable table;

  const TableDataCard({
    super.key,
    required this.table,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
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
                    Icons.table_chart_rounded,
                    size: 18,
                    color: DesignTokens.primaryLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tabel: ${table.name}',
                    style: AppTheme.monoStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              StatusPill(
                label: '${table.rows.length} baris',
                color: DesignTokens.primaryLight,
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 36,
              dataRowMinHeight: 32,
              dataRowMaxHeight: 36,
              columnSpacing: 20,
              horizontalMargin: 10,
              headingRowColor: WidgetStatePropertyAll(
                isDark ? const Color(0xFF252F3F) : const Color(0xFFEFF6FF),
              ),
              columns: table.columns
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
              rows: table.rows
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
      ),
    );
  }
}

/// SqlBlockChip & SqlBlockBuilder sesuai PRD Bagian 14 (Mode Blok "SQL Cooking Quest")
class SqlBlockChip extends StatelessWidget {
  final SqlBlockItem block;
  final VoidCallback? onTap;
  final bool isSelected;

  const SqlBlockChip({
    super.key,
    required this.block,
    this.onTap,
    this.isSelected = false,
  });

  Color get _blockColor {
    switch (block.type) {
      case SqlBlockType.keyword:
        return DesignTokens.blockKeyword;
      case SqlBlockType.column:
        return DesignTokens.blockColumn;
      case SqlBlockType.table:
        return DesignTokens.blockTable;
      case SqlBlockType.operatorType:
        return DesignTokens.blockOperator;
      case SqlBlockType.value:
        return DesignTokens.blockValue;
      case SqlBlockType.closing:
        return DesignTokens.blockClosing;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 40, minWidth: 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? _blockColor.withValues(alpha: 0.25)
                : _blockColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _blockColor,
              width: 1.5,
            ),
          ),
          child: Text(
            block.text,
            style: AppTheme.monoStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? _blockColor : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class SqlBlockBuilder extends StatelessWidget {
  final int slotCount;
  final List<SqlBlockItem?> filledSlots;
  final List<SqlBlockItem> availableBlocks;
  final ValueChanged<int> onRemoveSlot;
  final ValueChanged<SqlBlockItem> onSelectBlock;
  final VoidCallback onClearAll;

  const SqlBlockBuilder({
    super.key,
    required this.slotCount,
    required this.filledSlots,
    required this.availableBlocks,
    required this.onRemoveSlot,
    required this.onSelectBlock,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final usedIds =
        filledSlots.whereType<SqlBlockItem>().map((b) => b.id).toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Susun Query',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  TextButton.icon(
                    onPressed: onClearAll,
                    icon: const Icon(Icons.backspace_outlined, size: 16),
                    label: const Text('Hapus'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(slotCount, (index) {
                  final item =
                      index < filledSlots.length ? filledSlots[index] : null;
                  if (item != null) {
                    return SqlBlockChip(
                      block: item,
                      onTap: () => onRemoveSlot(index),
                    );
                  }
                  return Container(
                    width: 52,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: DesignTokens.primaryLight.withValues(alpha: 0.45),
                        width: 1.5,
                      ),
                      color: DesignTokens.primaryLight.withValues(alpha: 0.05),
                    ),
                    child: Text(
                      '?',
                      style: AppTheme.monoStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: DesignTokens.primaryLight,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilihan Blok SQL',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Ketuk blok untuk mengisi slot kosong berikutnya (hati-hati blok pengecoh!)',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableBlocks.map((block) {
                  final isUsed = usedIds.contains(block.id);
                  return SqlBlockChip(
                    block: block,
                    isSelected: isUsed,
                    onTap: isUsed ? null : () => onSelectBlock(block),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// PrimaryActionButton sesuai PRD Bagian 14 & 19 (varian dengan label XP hadiah)
class PrimaryActionButton extends StatelessWidget {
  final String label;
  final int? xpReward;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  const PrimaryActionButton({
    super.key,
    required this.label,
    this.xpReward,
    this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(label),
                  if (xpReward != null) ...[
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: DesignTokens.xpRewardLight,
                        borderRadius:
                            BorderRadius.circular(DesignTokens.pillRadius),
                      ),
                      child: Text(
                        '+$xpReward XP',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

/// BadgeTile sesuai PRD Bagian 14 & 18 #11 (Lebar minimum kartu badge dan teks maksimal dua baris dengan ellipsis)
class BadgeTile extends StatelessWidget {
  final AchievementModel achievement;
  final VoidCallback? onTap;

  const BadgeTile({
    super.key,
    required this.achievement,
    this.onTap,
  });

  IconData get _iconData {
    switch (achievement.iconName) {
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'terminal':
        return Icons.terminal_rounded;
      case 'sports_esports':
        return Icons.sports_esports_rounded;
      case 'workspace_premium':
        return Icons.workspace_premium_rounded;
      case 'local_fire_department':
        return Icons.local_fire_department_rounded;
      case 'military_tech':
        return Icons.military_tech_rounded;
      default:
        return Icons.emoji_events_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 128, maxWidth: 148),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: unlocked
                    ? DesignTokens.xpRewardLight.withValues(alpha: 0.16)
                    : Colors.grey.withValues(alpha: 0.15),
              ),
              child: Icon(
                _iconData,
                color: unlocked ? DesignTokens.xpRewardLight : Colors.grey,
                size: 26,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              achievement.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: unlocked ? null : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              unlocked ? '+${achievement.xpReward} XP' : 'Terkunci',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: unlocked ? DesignTokens.successLight : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// SettingsListTile sesuai PRD Bagian 19
class SettingsListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  const SettingsListTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? DesignTokens.primaryLight;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      onTap: onTap,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            )
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, size: 20),
    );
  }
}

/// AppBottomNav sesuai PRD MOB-01 & Bagian 14: 4 tab (Beranda, Belajar, Game, Profil)
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final AppStrings strings;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home_rounded),
          label: strings.homeTab,
        ),
        NavigationDestination(
          icon: const Icon(Icons.menu_book_outlined),
          selectedIcon: const Icon(Icons.menu_book_rounded),
          label: strings.learnTab,
        ),
        NavigationDestination(
          icon: const Icon(Icons.sports_esports_outlined),
          selectedIcon: const Icon(Icons.sports_esports_rounded),
          label: strings.gameTab,
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline_rounded),
          selectedIcon: const Icon(Icons.person_rounded),
          label: strings.profileTab,
        ),
      ],
    );
  }
}

/// ScreenStateWrapper sesuai MOB-02, Bagian 36, & AC-19:
/// Mendukung state loading (skeleton), empty, error (tombol coba lagi), offline banner, dan normal.
class ScreenStateWrapper extends StatelessWidget {
  final ScreenSimulatedState state;
  final Widget child;
  final String emptyMessage;
  final VoidCallback onRetry;

  const ScreenStateWrapper({
    super.key,
    required this.state,
    required this.child,
    this.emptyMessage = 'Belum ada data tersedia.',
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case ScreenSimulatedState.loading:
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 4,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return Container(
              height: index == 0 ? 120 : 88,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
              ),
            );
          },
        );
      case ScreenSimulatedState.empty:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.inbox_outlined,
                  size: 56,
                  color: Colors.grey,
                ),
                const SizedBox(height: 12),
                Text(
                  emptyMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Muat Ulang'),
                ),
              ],
            ),
          ),
        );
      case ScreenSimulatedState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 56,
                  color: DesignTokens.errorLight,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Terjadi kesalahan. Coba lagi sebentar lagi.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Request ID: req_sqlq_500_demo',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Coba lagi'),
                ),
              ],
            ),
          ),
        );
      case ScreenSimulatedState.offline:
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFFFEF3C7),
              child: Row(
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    size: 18,
                    color: Color(0xFFB45309),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Tidak ada koneksi internet. Menampilkan konten cache.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onRetry,
                    child: const Text('Online'),
                  ),
                ],
              ),
            ),
            Expanded(child: child),
          ],
        );
      case ScreenSimulatedState.normal:
        return child;
    }
  }
}
