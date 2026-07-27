class AuthResponse {
  final int id;
  final String fullName;
  final String email;
  final String accessToken;
  final String refreshToken;

  const AuthResponse({
    required this.id,
    required this.fullName,
    required this.email,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      id: json['id'] as int,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}
