import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

final _plugin = FlutterLocalNotificationsPlugin();

class NotificationManager {
  static final NotificationManager shared = NotificationManager._();
  NotificationManager._();

  Future<void> init() async {
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(const InitializationSettings(iOS: iosInit));
  }

  Future<bool> izinIste() async {
    final ios = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final result = await ios?.requestPermissions(alert: true, badge: true, sound: true);
    return result ?? false;
  }

  Future<void> gunlukBildirimAyarla(int saat) async {
    await bildirimleriIptalEt();

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, saat);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      0,
      'Günlük Motivasyon 💰',
      'Bugün finansal hedeflerinize bir adım daha yaklaşın!',
      scheduled,
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          categoryIdentifier: 'daily_motivation',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> bildirimleriIptalEt() async {
    await _plugin.cancelAll();
  }
}
