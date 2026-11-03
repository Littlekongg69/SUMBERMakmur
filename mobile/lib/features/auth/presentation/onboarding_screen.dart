import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/models/app_state_provider.dart';
import '../../../shared/widgets/sqlquest_widgets.dart';

/// Bagian 12 & AC-04:
/// Onboarding 4 pertanyaan (Level SQL, Pengalaman Database, Tujuan Belajar, Waktu Belajar)
/// diikuti layar rekomendasi path & izin kontekstual push notification (MOB-05).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _step = 0; // 0..3 questions, 4 = recommendation result
  String _sqlLevel = 'Dasar';
  String _dbExperience = 'Tidak ada';
  String _learningGoal = 'Tugas kuliah';
  int _dailyMinutes = 15;

  static const List<String> _sqlLevels = [
    'Belum pernah',
    'Dasar',
    'Menengah',
    'Mahir',
  ];

  static const List<String> _dbExperiences = [
    'Tidak ada',
    'Pernah memakai (MySQL, Postgres, Excel, dll.)',
    'Rutin bekerja dengan database',
  ];

  static const List<String> _learningGoals = [
    'Tugas kuliah',
    'Karier/pekerjaan',
    'Analisis data',
    'Hobi',
  ];

  static const List<int> _dailyMinuteOptions = [5, 15, 30, 60];

  String get _recommendedPathTitle {
    if (_sqlLevel == 'Menengah') return 'SQL Intermediate';
    if (_sqlLevel == 'Mahir') return 'SQL Advanced';
    return 'SQL Beginner';
  }

  void _finishOnboarding() {
    ref.read(appStateProvider.notifier).completeOnboarding(
          sqlLevel: _sqlLevel,
          dbExperience: _dbExperience,
          learningGoal: _learningGoal,
          dailyGoalMinutes: _dailyMinutes,
        );
    _showContextualPushPermissionDialog();
  }

  /// MOB-05: Izin push notification diminta kontekstual setelah onboarding, bukan saat peluncuran pertama
  Future<void> _showContextualPushPermissionDialog() async {
    final state = ref.read(appStateProvider);
    if (state.fcmPermissionRequested) {
      if (mounted) context.go('/home');
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aktifkan Pengingat Belajar?'),
        content: Text(
          'Kami akan mengirimkan pengingat harian pukul 19:00 lokal untuk menjaga streak dan target $_dailyMinutes menit/hari kamu (MOB-05).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Nanti Saja'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Izinkan Notifikasi'),
          ),
        ],
      ),
    );

    ref.read(appStateProvider.notifier).setFcmPermission(result ?? false);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalisasi Belajar'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(appStateProvider.notifier).skipOnboarding();
              context.go('/home');
            },
            child: const Text('Lewati'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _step < 4 ? _buildQuestionStep() : _buildRecommendationStep(),
        ),
      ),
    );
  }

  Widget _buildQuestionStep() {
    final titles = [
      '1. Apa level SQL kamu saat ini?',
      '2. Bagaimana pengalaman database kamu?',
      '3. Apa tujuan utama kamu belajar SQL?',
      '4. Berapa target waktu belajar kamu per hari?',
    ];

    final subtitles = [
      'Menentukan learning path awal yang terbuka untukmu.',
      'Menentukan lesson pertama yang paling pas.',
      'Menyesuaikan urutan rekomendasi challenge dan motivasi.',
      'Menentukan target misi harian "Study for X minutes" & pengingat 19:00.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        XpProgressBar(
          progress: (_step + 1) / 4.0,
          leftLabel: 'Pertanyaan ${_step + 1} dari 4',
          rightLabel: '${((_step + 1) * 25)}%',
          color: DesignTokens.primaryLight,
        ),
        const SizedBox(height: 24),
        Text(
          titles[_step],
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          subtitles[_step],
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.65),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView(
            children: _buildOptionsForCurrentStep(),
          ),
        ),
        Row(
          children: [
            if (_step > 0) ...[
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () => setState(() => _step--),
                  child: const Text('Kembali'),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => setState(() => _step++),
                child: Text(_step == 3 ? 'Lihat Rekomendasi' : 'Lanjut'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildOptionsForCurrentStep() {
    if (_step == 0) {
      return _sqlLevels.map((lvl) {
        final selected = _sqlLevel == lvl;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            onTap: () => setState(() => _sqlLevel = lvl),
            borderColor: selected ? DesignTokens.primaryLight : null,
            borderWidth: selected ? 2 : 1,
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? DesignTokens.primaryLight : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    lvl,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList();
    } else if (_step == 1) {
      return _dbExperiences.map((exp) {
        final selected = _dbExperience == exp;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            onTap: () => setState(() => _dbExperience = exp),
            borderColor: selected ? DesignTokens.primaryLight : null,
            borderWidth: selected ? 2 : 1,
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? DesignTokens.primaryLight : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    exp,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList();
    } else if (_step == 2) {
      return _learningGoals.map((goal) {
        final selected = _learningGoal == goal;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            onTap: () => setState(() => _learningGoal = goal),
            borderColor: selected ? DesignTokens.primaryLight : null,
            borderWidth: selected ? 2 : 1,
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? DesignTokens.primaryLight : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    goal,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList();
    } else {
      return _dailyMinuteOptions.map((mins) {
        final selected = _dailyMinutes == mins;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            onTap: () => setState(() => _dailyMinutes = mins),
            borderColor: selected ? DesignTokens.primaryLight : null,
            borderWidth: selected ? 2 : 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: selected ? DesignTokens.primaryLight : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$mins menit / hari',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                StatusPill(
                  label: mins <= 15 ? 'Konsisten' : 'Intensif',
                  color: DesignTokens.primaryLight,
                ),
              ],
            ),
          ),
        );
      }).toList();
    }
  }

  Widget _buildRecommendationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StatusPill(
          label: 'Rekomendasi Kurikulum',
          color: DesignTokens.successLight,
        ),
        const SizedBox(height: 12),
        const Text(
          'Jalur Belajar Kamu Siap!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Berdasarkan profilmu ($_sqlLevel · $_learningGoal), kami merekomendasikan path berikut:',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 20),
        AppCard(
          gradient: DesignTokens.heroCardGradient,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius:
                          BorderRadius.circular(DesignTokens.pillRadius),
                    ),
                    child: const Text(
                      'Direkomendasikan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Icon(Icons.auto_awesome_rounded, color: Colors.amber),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _recommendedPathTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lesson pertama: ${_dbExperience == 'Tidak ada' ? 'Introduction to Database' : 'SQL Basics & SELECT'}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Target harian: $_dailyMinutes menit/hari · Pengingat pukul 19:00 lokal',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        PrimaryActionButton(
          label: 'Mulai Belajar Sekarang',
          icon: Icons.rocket_launch_rounded,
          onPressed: _finishOnboarding,
        ),
      ],
    );
  }
}

