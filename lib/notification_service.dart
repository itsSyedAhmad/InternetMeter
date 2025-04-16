import 'package:flutter_internet_meter/storage_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _notifications.initialize(initSettings);
  }

  static Future<void> showSpeedNotification(double kbps  ) async {
    final androidDetails = AndroidNotificationDetails(
      'speed_channel',
      'Speed Monitor',
      channelDescription: 'Shows internet speed in notification',
      importance: Importance.high,
      priority: Priority.high,
      onlyAlertOnce: true,
      showWhen: false,
    );

    await _notifications.show(
      0,
      'Speed Monitor',
      '${kbps.toStringAsFixed(2)} KB/s',
      NotificationDetails(android: androidDetails),
    );
    DataUsageStorageService.writeFunction(DateTime.now(), false, kbps.round());
  }
}
