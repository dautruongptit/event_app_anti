import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Screens
import '../../ui/screens/splash_screen.dart';
import '../../ui/screens/auth/login_screen.dart';
import '../../ui/screens/auth/register_screen.dart';
import '../../ui/screens/home/home_screen.dart';
import '../../ui/screens/events/event_list_screen.dart';
import '../../ui/screens/events/event_form_screen.dart';
import '../../ui/screens/events/event_detail_screen.dart';
import '../../ui/screens/events/event_type_selection_screen.dart';
import '../../ui/screens/relatives/relative_list_screen.dart';
import '../../ui/screens/relatives/relative_form_screen.dart';
import '../../ui/screens/relatives/relative_detail_screen.dart';
import '../../ui/screens/notifications/notification_screen.dart';
import '../../ui/screens/profile/profile_screen.dart';
import '../../ui/screens/profile/login_history_screen.dart';
import '../../ui/screens/settings/settings_screen.dart';
import '../../ui/widgets/bottom_nav_scaffold.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

  /// Cho phép điều hướng từ nơi không có BuildContext (vd: callback của
  /// FirebaseMessaging khi user bấm vào push notification).
  static GlobalKey<NavigatorState> get navigatorKey => _rootNavigatorKey;

  static GoRouter createRouter() {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      redirect: (BuildContext context, GoRouterState state) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('accessToken');
        final isLoggedIn = token != null && token.isNotEmpty;
        final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';
        final isSplashRoute = state.matchedLocation == '/splash';

        if (!isLoggedIn && !isAuthRoute && !isSplashRoute) {
          return '/login';
        }

        // Đã đăng nhập (kể cả phiên cũ khôi phục lại) mà đang ở màn splash/
        // login/register -> vào thẳng Home, không kẹt lại màn quảng cáo.
        if (isLoggedIn && (isAuthRoute || isSplashRoute)) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        // 4-tab bottom navigation: Home / Người thân / Sự kiện / Tôi
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return BottomNavScaffold(navigationShell: navigationShell);
          },
          branches: [
            // Tab 0: Home
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
            // Tab 1: Người thân
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/relatives',
                  builder: (context, state) => const RelativeListScreen(),
                  routes: [
                    GoRoute(
                      path: 'create',
                      builder: (context, state) => const RelativeFormScreen(),
                    ),
                    GoRoute(
                      path: ':id',
                      builder: (context, state) {
                        final id = int.parse(state.pathParameters['id']!);
                        return RelativeDetailScreen(id: id);
                      },
                      routes: [
                        GoRoute(
                          path: 'edit',
                          builder: (context, state) {
                            final id = int.parse(state.pathParameters['id']!);
                            return RelativeFormScreen(relativeId: id);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            // Tab 2: Sự kiện
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/events',
                  builder: (context, state) => const EventListScreen(),
                  routes: [
                    GoRoute(
                      path: 'new',
                      builder: (context, state) => const EventTypeSelectionScreen(),
                    ),
                    GoRoute(
                      path: 'create',
                      builder: (context, state) {
                        final type = state.uri.queryParameters['type'];
                        return EventFormScreen(
                          isRelativeEvent: type != 'self',
                        );
                      },
                    ),
                    GoRoute(
                      path: ':id',
                      builder: (context, state) {
                        final id = int.parse(state.pathParameters['id']!);
                        return EventDetailScreen(eventId: id);
                      },
                      routes: [
                        GoRoute(
                          path: 'edit',
                          builder: (context, state) {
                            final id = int.parse(state.pathParameters['id']!);
                            return EventFormScreen(eventId: id);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            // Tab 3: Tôi (Profile)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const ProfileScreen(),
                  routes: [
                    GoRoute(
                      path: 'settings',
                      builder: (context, state) => const SettingsScreen(),
                    ),
                    GoRoute(
                      path: 'notifications',
                      builder: (context, state) => const NotificationScreen(),
                    ),
                    GoRoute(
                      path: 'login-history',
                      builder: (context, state) => const LoginHistoryScreen(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
