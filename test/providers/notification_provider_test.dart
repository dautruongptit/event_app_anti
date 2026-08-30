import 'package:flutter_test/flutter_test.dart';
import 'package:event_app/core/network/dio_client.dart';
import 'package:event_app/providers/notification_provider.dart';
import 'package:event_app/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late NotificationProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    provider = NotificationProvider(NotificationService(DioClient(prefs)));
  });

  group('notifyNewNotification (FCM foreground push -> bell shake trigger)', () {
    test('starts at 0', () {
      expect(provider.newNotificationTick, 0);
    });

    test('increments the tick each call, so widgets can detect a fresh push even with identical unreadCount', () {
      provider.notifyNewNotification();
      expect(provider.newNotificationTick, 1);

      provider.notifyNewNotification();
      expect(provider.newNotificationTick, 2);
    });

    test('notifies listeners so the bell icon can rebuild and shake', () {
      var notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.notifyNewNotification();

      expect(notifyCount, 1);
    });
  });
}
