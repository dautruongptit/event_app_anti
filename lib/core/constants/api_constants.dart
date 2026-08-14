class ApiConstants {
  static const String baseUrl = 'https://event.thongtinchinhhieu.site';
  static const String baseUrlTailscale = 'http://100.101.239.103:8080';
  static const String apiPrefix = '/api/v1';

  // Auth
  static const String register = '$apiPrefix/auth/register';
  static const String login = '$apiPrefix/auth/login';
  static const String refresh = '$apiPrefix/auth/refresh';
  static const String logout = '$apiPrefix/auth/logout';

  // User (đúng theo UserController backend — KHÔNG có prefix /auth)
  static const String userProfile = '$apiPrefix/users/me';
  static const String updateProfile = '$apiPrefix/users/me';
  static const String updateSettings = '$apiPrefix/users/me/settings';
  static const String uploadAvatar = '$apiPrefix/users/me/avatar';
  static const String loginHistory = '$apiPrefix/users/me/login-history';
  // ⚠️ Backend chưa có controller cho endpoint này (chỉ có service placeholder,
  // chưa nối route) — gọi sẽ 404. Giữ lại hằng số để dễ nối khi SEC-31 xong.
  static const String connectGoogleCalendar =
      '$apiPrefix/users/me/google-calendar';

  // Events
  static const String events = '$apiPrefix/events';
  static const String upcomingEvents = '$apiPrefix/events/upcoming';
  static String eventById(int id) => '$apiPrefix/events/$id';

  // Home
  static const String home = '$apiPrefix/home';
  static const String myEvents = '$apiPrefix/home/my-events';

  // Notifications
  static const String notifications = '$apiPrefix/notifications';
  static const String unreadCount = '$apiPrefix/notifications/unread-count';
  static String markAsRead(int id) => '$apiPrefix/notifications/$id/read';
  static const String markAllAsRead = '$apiPrefix/notifications/read-all';

  // Relatives
  static const String relatives = '$apiPrefix/relatives';
  static const String relativeGroups = '$apiPrefix/relatives/groups';
  static String relativeById(int id) => '$apiPrefix/relatives/$id';
}
