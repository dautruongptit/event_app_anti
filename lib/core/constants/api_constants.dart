class ApiConstants {
  // TẠM THỜI trỏ về backend chạy local trên máy host để test — 10.0.2.2 là
  // địa chỉ đặc biệt Android emulator dùng để gọi về localhost của máy host.
  // Đổi lại 'https://event.thongtinchinhhieu.site' khi test xong.
  static const String baseUrl = 'http://10.0.2.2:8080';
  static const String baseUrlProd = 'https://event.thongtinchinhhieu.site';
  static const String baseUrlTailscale = 'http://100.101.239.103:8080';
  static const String apiPrefix = '/api/v1';

  // Auth
  static const String register = '$apiPrefix/auth/register';
  static const String login = '$apiPrefix/auth/login';
  static const String googleLogin = '$apiPrefix/auth/google';
  static const String refresh = '$apiPrefix/auth/refresh';
  static const String logout = '$apiPrefix/auth/logout';

  // OAuth 2.0 Web Client ID — project envent-app-22ba3 (Firebase Console >
  // Project settings > General > app Android > google-services.json,
  // oauth_client client_type: 3). Phải trùng GOOGLE_CLIENT_ID backend (.env).
  static const String googleServerClientId =
      '210357802583-eapeoeg41jbba9m152ai6v0hsei04ea7.apps.googleusercontent.com';

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
  static const String eventCategories = '$apiPrefix/events/categories';
  static String eventById(int id) => '$apiPrefix/events/$id';

  // Home
  static const String home = '$apiPrefix/home';
  static const String myEvents = '$apiPrefix/home/my-events';

  // Notifications
  static const String notifications = '$apiPrefix/notifications';
  static const String unreadCount = '$apiPrefix/notifications/unread-count';
  static String markAsRead(int id) => '$apiPrefix/notifications/$id/read';
  static const String markAllAsRead = '$apiPrefix/notifications/read-all';

  // Devices (đăng ký FCM token — xem DeviceController.java backend)
  static const String devices = '$apiPrefix/users/me/devices';

  // Relatives
  static const String relatives = '$apiPrefix/relatives';
  static const String relativeGroups = '$apiPrefix/relatives/groups';
  static String relativeById(int id) => '$apiPrefix/relatives/$id';
}
