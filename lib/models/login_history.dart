class LoginHistoryModel {
  final int id;
  final String? ipAddress;
  final String? deviceType; // Mobile | Desktop | Tablet
  final String? os; // Windows | macOS | Android | iOS
  final String? browser;
  final String? country;
  final bool isSuccess;
  final String? failureReason;
  final DateTime loginAt;

  const LoginHistoryModel({
    required this.id,
    this.ipAddress,
    this.deviceType,
    this.os,
    this.browser,
    this.country,
    this.isSuccess = true,
    this.failureReason,
    required this.loginAt,
  });

  factory LoginHistoryModel.fromJson(Map<String, dynamic> json) {
    return LoginHistoryModel(
      id: json['id'] as int,
      ipAddress: json['ipAddress'] as String?,
      deviceType: json['deviceType'] as String?,
      os: json['os'] as String?,
      browser: json['browser'] as String?,
      country: json['country'] as String?,
      isSuccess: json['isSuccess'] as bool? ?? true,
      failureReason: json['failureReason'] as String?,
      loginAt: DateTime.parse(json['loginAt'] as String),
    );
  }

  /// Nhãn thiết bị hiển thị, ví dụ "Android - Chrome".
  String get deviceLabel {
    final parts = [
      if (os != null && os!.isNotEmpty) os,
      if (browser != null && browser!.isNotEmpty) browser,
    ];
    if (parts.isEmpty) return deviceType ?? 'Không rõ thiết bị';
    return parts.join(' - ');
  }
}
