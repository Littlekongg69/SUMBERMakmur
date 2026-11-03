import '../../../shared/models/app_models.dart';

abstract class NotificationRepository {
  List<AppNotificationModel> getNotifications();
}

