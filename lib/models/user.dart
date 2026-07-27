class UserProfile {
  final int id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String language;
  final bool darkMode;
  final int totalEvents;
  final int totalRelatives;
  final int? daysUntilNextEvent;
  final bool? googleCalendarConnected;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.language = 'vi',
    this.darkMode = false,
    this.totalEvents = 0,
    this.totalRelatives = 0,
    this.daysUntilNextEvent,
    this.googleCalendarConnected,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      language: json['language'] as String? ?? 'vi',
      darkMode: json['darkMode'] as bool? ?? false,
      totalEvents: json['totalEvents'] as int? ?? 0,
      totalRelatives: json['totalRelatives'] as int? ?? 0,
      daysUntilNextEvent: json['daysUntilNextEvent'] as int?,
      googleCalendarConnected: json['googleCalendarConnected'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'avatarUrl': avatarUrl,
      'language': language,
      'darkMode': darkMode,
      'totalEvents': totalEvents,
      'totalRelatives': totalRelatives,
      'daysUntilNextEvent': daysUntilNextEvent,
      'googleCalendarConnected': googleCalendarConnected,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? fullName,
    String? avatarUrl,
    String? language,
    bool? darkMode,
    int? totalEvents,
    int? totalRelatives,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      language: language ?? this.language,
      darkMode: darkMode ?? this.darkMode,
      totalEvents: totalEvents ?? this.totalEvents,
      totalRelatives: totalRelatives ?? this.totalRelatives,
      daysUntilNextEvent: daysUntilNextEvent,
      googleCalendarConnected: googleCalendarConnected,
      createdAt: createdAt,
    );
  }
}
