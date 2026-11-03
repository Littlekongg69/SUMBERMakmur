import '../../../shared/models/app_models.dart';
import '../../../shared/models/app_state_provider.dart';
import '../domain/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final AppState state;
  NotificationRepositoryImpl(this.state);

  @override
  List<AppNotificationModel> getNotifications() => state.notifications;
}

