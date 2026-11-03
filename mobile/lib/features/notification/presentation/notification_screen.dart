import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/models/app_models.dart';
import '../../../shared/models/app_state_provider.dart';
import '../../../shared/widgets/sqlquest_widgets.dart';

/// Bagian 25 & FR-NTF-01:
/// Pusat Notifikasi in-app untuk level up, achievement terbuka, dan misi selesai.
/// Dapat ditandai dibaca satu per satu atau semuanya.
class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  IconData _iconForType(String type) {
    switch (type) {
      case 'level_up':
        return Icons.trending_up_rounded;
      case 'achievement_unlocked':
        return Icons.emoji_events_rounded;
      default:
        return Icons.flag_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    final notifications = state.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          if (state.unreadNotificationCount > 0)
            TextButton(
              onPressed: () => ref
                  .read(appStateProvider.notifier)
                  .markAllNotificationsRead(),
              child: const Text('Tandai Semua Dibaca'),
            ),
        ],
      ),
      body: ScreenStateWrapper(
        state: state.simulatedState,
        emptyMessage: 'Belum ada notifikasi baru.',
        onRetry: () => ref
            .read(appStateProvider.notifier)
            .setSimulatedState(ScreenSimulatedState.normal),
        child: notifications.isEmpty
            ? const Center(child: Text('Belum ada notifikasi.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, idx) {
                  final n = notifications[idx];
                  return AppCard(
                    borderColor:
                        n.isRead ? null : DesignTokens.primaryLight,
                    borderWidth: n.isRead ? 1 : 1.5,
                    onTap: () {
                      ref
                          .read(appStateProvider.notifier)
                          .markNotificationRead(n.id);
                      if (n.deepLink != null) {
                        context.push(n.deepLink!);
                      }
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: DesignTokens.primaryLight
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _iconForType(n.type),
                            color: DesignTokens.primaryLight,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      n.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: n.isRead
                                            ? FontWeight.w600
                                            : FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  if (!n.isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: DesignTokens.primaryLight,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                n.body,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

