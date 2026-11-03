import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/leaderboard/presentation/leaderboard_screen.dart';
import '../../features/learning/presentation/learning_path_screen.dart';
import '../../features/learning/presentation/lesson_screen.dart';
import '../../features/learning/presentation/quiz_screen.dart';
import '../../features/mission/presentation/daily_mission_screen.dart';
import '../../features/notification/presentation/notification_screen.dart';
import '../../features/profile/presentation/achievement_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../../features/sql_game/presentation/sql_challenge_screen.dart';
import '../../features/sql_game/presentation/sql_game_screen.dart';
import '../../shared/models/app_state_provider.dart';
import '../../shared/widgets/sqlquest_widgets.dart';

/// Bagian 13, 14 (MOB-01, MOB-07), & 36:
/// Konfigurasi GoRouter dengan StatefulShellRoute.indexedStack (mempertahankan state 4 tab),
/// Auth guard, deep link sqlquest://challenge/:id, serta layar 403 & 404.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    redirect: (context, routerState) {
      final loc = routerState.uri.toString();
      // MOB-07: Deep link sqlquest://challenge/:id
      if (loc.startsWith('sqlquest://challenge/')) {
        final id = loc.replaceFirst('sqlquest://challenge/', '');
        return '/game/challenges/$id';
      }
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('404 — Halaman Tidak Ditemukan')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.explore_off_rounded, size: 56, color: Colors.grey),
              const SizedBox(height: 12),
              const Text(
                'Konten tidak ditemukan.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Kembali ke Beranda'),
              ),
            ],
          ),
        ),
      ),
    ),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      // AC-15: Rute /admin mengembalikan 403 Forbidden bagi role user
      GoRoute(
        path: '/admin',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('403 — Akses Ditolak')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.gpp_bad_rounded,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Kamu tidak memiliki akses ke halaman ini (403 FORBIDDEN).',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Kembali ke Beranda'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // MOB-01: Bottom navigation 4 tab (Beranda, Belajar, Game, Profil) mempertahankan state tab
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _MainShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/learn',
                builder: (context, state) => const LearningPathScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/game',
                builder: (context, state) => const SqlGameScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Layar turunan di luar shell tab
      GoRoute(
        path: '/lessons/:id',
        builder: (context, state) => LessonScreen(
          lessonId: state.pathParameters['id'] ?? 'les-1',
        ),
      ),
      GoRoute(
        path: '/lessons/:id/quiz',
        builder: (context, state) => QuizScreen(
          lessonId: state.pathParameters['id'] ?? 'les-1',
        ),
      ),
      GoRoute(
        path: '/game/challenges/:id',
        builder: (context, state) => SqlChallengeScreen(
          challengeId: state.pathParameters['id'] ?? 'chal-1',
        ),
      ),
      GoRoute(
        path: '/missions',
        builder: (context, state) => const DailyMissionScreen(),
      ),
      GoRoute(
        path: '/leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: '/achievements',
        builder: (context, state) => const AchievementScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

class _MainShellScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const _MainShellScaffold({required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStateProvider).strings;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        strings: strings,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

