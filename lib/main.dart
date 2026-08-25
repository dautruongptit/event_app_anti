import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/network/dio_client.dart';
import 'core/theme/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/home_provider.dart';
import 'providers/event_provider.dart';
import 'providers/relative_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/locale_provider.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/home_service.dart';
import 'services/event_service.dart';
import 'services/relative_service.dart';
import 'services/notification_service.dart';
import 'services/device_service.dart';
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final dioClient = DioClient(prefs);

  // Services
  final authService = AuthService(dioClient);
  final userService = UserService(dioClient);
  final homeService = HomeService(dioClient);
  final eventService = EventService(dioClient);
  final relativeService = RelativeService(dioClient);
  final notificationService = NotificationService(dioClient);
  final deviceService = DeviceService(dioClient);
  final fcmService = FcmService(deviceService);
  // Phải init trước runApp: đăng ký background handler của FCM chỉ có tác
  // dụng nếu gọi trước khi app thực sự chạy.
  await fcmService.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<SharedPreferences>.value(value: prefs),
        Provider<DioClient>.value(value: dioClient),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(create: (_) => LocaleProvider()..loadSavedLocale()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService, userService, dioClient, null, fcmService),
        ),
        ChangeNotifierProvider(create: (_) => HomeProvider(homeService)),
        ChangeNotifierProvider(create: (_) => EventProvider(eventService)),
        ChangeNotifierProvider(create: (_) => RelativeProvider(relativeService)),
        ChangeNotifierProvider(create: (_) => NotificationProvider(notificationService)),
      ],
      child: const AppWidget(),
    ),
  );
}
