class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8080';
  static const String apiPrefix = '/api/v1';

  // Auth
  static const String register = '$apiPrefix/auth/register';
  static const String login = '$apiPrefix/auth/login';
  static const String refresh = '$apiPrefix/auth/refresh';
  static const String logout = '$apiPrefix/auth/logout';
  static const String updateProfile = '$apiPrefix/auth/users/me';
  static const String updateSettings = '$apiPrefix/auth/users/me/settings';
  static const String uploadAvatar = '$apiPrefix/auth/users/me/avatar';
  static const String connectGoogleCalendar =
      '$apiPrefix/auth/users/me/google-calendar';

  // User
  static const String userProfile = '$apiPrefix/users/me';

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
