import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/models/app_state_provider.dart';
import '../../../shared/widgets/sqlquest_widgets.dart';

/// Bagian 14 (Layar Belajar):
/// - Pencarian dengan debounce 300 ms
/// - Tab filter: Semua, Sedang berjalan, Selesai
/// - Kartu modul berurutan berdasarkan position (World n)
/// - Modul aktif disorot border biru + tombol "Lanjutkan Belajar"
/// - Modul terkunci menampilkan bottom sheet syarat pembukaan
///
/// Perubahan desain:
/// - Daftar lesson dikelompokkan dalam satu panel per modul, bukan ListTile lepas.
/// - Lesson modul yang sedang berjalan terbuka, modul lain dilipat (bisa dibuka manual).
/// - Filter status memakai tab bergaris bawah agar tidak tertukar dengan chip path.
class LearningPathScreen extends ConsumerStatefulWidget {
  const LearningPathScreen({super.key});

  @override
  ConsumerState<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends ConsumerState<LearningPathScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _query = '';
  String _statusFilter = 'all'; // all, in_progress, completed
  String? _selectedPathId;

  /// Status buka/tutup manual daftar lesson per modul. Bila belum diubah
  /// pengguna, modul yang sedang berjalan terbuka secara default.
  final Map<String, bool> _expandedOverride = {};

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _query = value.trim().toLowerCase());
      }
    });
  }

  String? _currentLessonId(ModuleModel mod) {
    for (final l in mod.lessons) {
      if (l.status != 'completed' && l.status != 'locked') return l.id;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateProvider);
    final strings = state.strings;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentPath = state.paths.firstWhere(
          (p) => p.id == (_selectedPathId ?? state.user.recommendedPathId),
      orElse: () => state.paths.first,
    );
    final isPathLocked = state.isPathLocked(currentPath);

    // Filter modules by search query & status filter
    final filteredModules = currentPath.modules.where((m) {
      if (_statusFilter == 'in_progress' && m.status != 'in_progress') {
        return false;
      }
      if (_statusFilter == 'completed' && m.status != 'completed') {
        return false;
      }
      if (_query.isEmpty) return true;
      final matchMod = m.title.toLowerCase().contains(_query) ||
          m.description.toLowerCase().contains(_query);
      final matchLes = m.lessons.any(
            (l) =>
        l.title.toLowerCase().contains(_query) ||
            l.description.toLowerCase().contains(_query),
      );
      return matchMod || matchLes;
    }).toList();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? DesignTokens.darkPageGradient
              : DesignTokens.lightPageGradient,
        ),
        child: SafeArea(
          child: ScreenStateWrapper(
            state: state.simulatedState,
            emptyMessage: strings.emptyMaterials,
            onRetry: () => ref
                .read(appStateProvider.notifier)
                .setSimulatedState(ScreenSimulatedState.normal),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Text(
                  strings.learnTab,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kurikulum PostgreSQL dari Beginner hingga Advanced',
                  style: TextStyle(fontSize: 13, color: _mutedText(context)),
                ),
                const SizedBox(height: 16),

                // Field pencarian (debounce 300 ms)
                TextField(
                  controller: _searchCtrl,
                  onChanged: _onSearchChanged,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: strings.searchMaterialHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                      tooltip: 'Hapus pencarian',
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.clear_rounded),
                    )
                        : null,
                  ),
                ),
                const SizedBox(height: 14),

                // Pilihan learning path
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.paths.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final path = state.paths[idx];
                      final selected = path.id == currentPath.id;
                      final locked = state.isPathLocked(path);
                      return ChoiceChip(
                        selected: selected,
                        showCheckmark: false,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (locked) ...[
                              const Icon(Icons.lock_outline_rounded, size: 15),
                              const SizedBox(width: 4),
                            ],
                            Text(path.title),
                          ],
                        ),
                        onSelected: (_) {
                          setState(() => _selectedPathId = path.id);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Ringkasan path aktif
                _PathSummaryCard(
                  path: currentPath,
                  isLocked: isPathLocked,
                ),
                const SizedBox(height: 16),

                // Tab filter
                _FilterTabs(
                  labels: {
                    'all': strings.filterAll,
                    'in_progress': strings.filterInProgress,
                    'completed': strings.filterCompleted,
                  },
                  selected: _statusFilter,
                  onChanged: (v) => setState(() => _statusFilter = v),
                ),
                const SizedBox(height: 16),

                // Daftar modul
                if (filteredModules.isEmpty)
                  _EmptyModules(
                    message: _query.isNotEmpty
                        ? 'Tidak ada modul atau lesson untuk "$_query"'
                        : strings.emptyMaterials,
                  )
                else
                  ...filteredModules.map((mod) {
                    final modLocked = isPathLocked || mod.status == 'locked';
                    final key = '${currentPath.id}:${mod.title}';
                    final searching = _query.isNotEmpty;
                    final expanded = searching ||
                        (_expandedOverride[key] ?? mod.status == 'in_progress');
                    final currentLessonId = _currentLessonId(mod);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ModuleCard(
                            module: mod,
                            onTap: () {
                              if (modLocked) {
                                _showLockedBottomSheet(
                                  context,
                                  mod,
                                  isPathLocked
                                      ? currentPath.prerequisiteTitle
                                      : mod.prerequisiteModuleTitle,
                                );
                              } else {
                                context.push(
                                  '/lessons/${mod.activeOrFirstLesson.id}',
                                );
                              }
                            },
                          ),
                          if (!modLocked) ...[
                            if (!searching)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: () => setState(
                                        () => _expandedOverride[key] = !expanded,
                                  ),
                                  icon: Icon(
                                    expanded
                                        ? Icons.expand_less_rounded
                                        : Icons.expand_more_rounded,
                                    size: 20,
                                  ),
                                  label: Text(
                                    expanded
                                        ? 'Sembunyikan lesson'
                                        : 'Lihat ${mod.lessons.length} lesson',
                                  ),
                                ),
                              ),
                            if (expanded)
                              _LessonPanel(
                                lessons: mod.lessons,
                                currentLessonId: currentLessonId,
                                cachedIds: state.cachedLessonIds,
                                onTap: (les) {
                                  if (les.status == 'locked') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Selesaikan lesson sebelumnya secara berurutan di modul ini.',
                                        ),
                                      ),
                                    );
                                  } else {
                                    context.push('/lessons/${les.id}');
                                  }
                                },
                              ),
                          ],
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLockedBottomSheet(
      BuildContext context,
      ModuleModel mod,
      String? prereqTitle,
      ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.lock_rounded,
                  color: DesignTokens.xpRewardLight,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Modul terkunci: ${mod.title}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Syarat pembukaan: selesaikan seluruh lesson wajib pada "${prereqTitle ?? 'modul prasyarat sebelumnya'}" terlebih dahulu.',
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Mengerti'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _mutedText(BuildContext context) =>
    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65);

// ---------------------------------------------------------------------------
// Ringkasan path
// ---------------------------------------------------------------------------

class _PathSummaryCard extends StatelessWidget {
  final LearningPathModel path;
  final bool isLocked;

  const _PathSummaryCard({required this.path, required this.isLocked});

  @override
  Widget build(BuildContext context) {
    final statusLabel = isLocked
        ? 'Locked'
        : path.progressPercent == 100
        ? 'Completed'
        : path.progressPercent > 0
        ? 'In Progress'
        : 'Available';

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  path.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StatusPill(
                label: statusLabel,
                color: isLocked ? _mutedText(context) : DesignTokens.primaryLight,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            path.description,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: _mutedText(context),
            ),
          ),
          const SizedBox(height: 14),
          if (isLocked)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DesignTokens.xpRewardLight.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_rounded,
                    size: 18,
                    color: DesignTokens.xpRewardLight,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Selesaikan path prasyarat "${path.prerequisiteTitle}" terlebih dahulu.',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            XpProgressBar(
              progress: path.progressPercent / 100.0,
              leftLabel:
              '${path.completedLessons}/${path.totalLessons} lesson selesai',
              rightLabel: '${path.progressPercent}%',
              color: DesignTokens.primaryLight,
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab filter bergaris bawah
// ---------------------------------------------------------------------------

class _FilterTabs extends StatelessWidget {
  final Map<String, String> labels;
  final String selected;
  final ValueChanged<String> onChanged;

  const _FilterTabs({
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final line = Theme.of(context).dividerColor.withValues(alpha: 0.6);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: line)),
      ),
      child: Row(
        children: labels.entries.map((e) {
          final isSelected = e.key == selected;
          return Expanded(
            child: Semantics(
              button: true,
              selected: isSelected,
              child: InkWell(
                onTap: () => onChanged(e.key),
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 3,
                        color: isSelected
                            ? DesignTokens.primaryLight
                            : Colors.transparent,
                      ),
                    ),
                  ),
                  child: Text(
                    e.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? DesignTokens.primaryLight
                          : _mutedText(context),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Panel lesson dalam satu modul
// ---------------------------------------------------------------------------

class _LessonPanel extends StatelessWidget {
  final List<LessonModel> lessons;
  final String? currentLessonId;
  final Iterable<String> cachedIds;
  final ValueChanged<LessonModel> onTap;

  const _LessonPanel({
    required this.lessons,
    required this.currentLessonId,
    required this.cachedIds,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final line = Theme.of(context).dividerColor.withValues(alpha: 0.6);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Material(
        color: scheme.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: line),
        ),
        child: Column(
          children: [
            for (var i = 0; i < lessons.length; i++) ...[
              if (i > 0) Divider(height: 1, indent: 56, color: line),
              _LessonRow(
                lesson: lessons[i],
                isCurrent: lessons[i].id == currentLessonId,
                isCached: cachedIds.contains(lessons[i].id),
                onTap: () => onTap(lessons[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  final LessonModel lesson;
  final bool isCurrent;
  final bool isCached;
  final VoidCallback onTap;

  const _LessonRow({
    required this.lesson,
    required this.isCurrent,
    required this.isCached,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final done = lesson.status == 'completed';
    final locked = lesson.status == 'locked';
    final muted = _mutedText(context);

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              _LessonStatusDot(done: done, locked: locked, current: isCurrent),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${lesson.position}. ${lesson.title}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                        color: locked ? muted : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${lesson.estimatedMinutes} menit · +${lesson.xpReward} XP${isCached ? ' · Siap offline' : ''}',
                      style: TextStyle(fontSize: 12, color: muted),
                    ),
                  ],
                ),
              ),
              if (!locked)
                Icon(Icons.chevron_right_rounded, size: 20, color: muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _LessonStatusDot extends StatelessWidget {
  final bool done;
  final bool locked;
  final bool current;

  const _LessonStatusDot({
    required this.done,
    required this.locked,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    final muted = _mutedText(context);
    late final Color bg;
    late final Color fg;
    late final IconData icon;

    if (done) {
      bg = DesignTokens.successLight;
      fg = Colors.white;
      icon = Icons.check_rounded;
    } else if (locked) {
      bg = muted.withValues(alpha: 0.14);
      fg = muted;
      icon = Icons.lock_outline_rounded;
    } else if (current) {
      bg = DesignTokens.primaryLight;
      fg = Colors.white;
      icon = Icons.play_arrow_rounded;
    } else {
      bg = DesignTokens.primaryLight.withValues(alpha: 0.12);
      fg = DesignTokens.primaryLight;
      icon = Icons.play_arrow_rounded;
    }

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, size: 18, color: fg),
    );
  }
}

// ---------------------------------------------------------------------------
// State kosong
// ---------------------------------------------------------------------------

class _EmptyModules extends StatelessWidget {
  final String message;
  const _EmptyModules({required this.message});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 44,
            color: _mutedText(context),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}