import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:event_app/core/constants/api_constants.dart';

/// Bọc google_sign_in v6 (API cũ: GoogleSignIn().signIn(), không qua
/// Android Credential Manager) thành một hàm đơn giản trả về Google
/// idToken, để gửi lên backend (POST /auth/google — xem GoogleAuthService.java).
///
/// Dùng v6 thay vì v7 vì v7 chuyển sang Credential Manager API, hiện fail
/// nội bộ trên nhiều emulator (lỗi "GoogleSignIn_flowRunner Flow failed"
/// từ chính Google Play Services, không phải lỗi code) khiến không test
/// được trên máy ảo. v6 dùng luồng Sign-In cũ, ổn định hơn trên emulator.
class GoogleAuthHelper {
  final GoogleSignIn _signIn = GoogleSignIn(
    scopes: const ['email'],
    serverClientId: ApiConstants.googleServerClientId,
  );

  /// Mở luồng đăng nhập Google, trả về idToken để verify ở backend.
  /// Trả về null nếu người dùng chủ động huỷ (không tính là lỗi).
  /// Ném Exception nếu Google Sign-In thất bại vì lý do khác.
  Future<String?> signInAndGetIdToken() async {
    try {
      final account = await _signIn.signIn();
      if (account == null) return null; // Người dùng huỷ hộp thoại chọn tài khoản.

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        throw Exception('Google không trả về idToken, vui lòng thử lại');
      }
      return idToken;
    } on PlatformException catch (e) {
      throw Exception('Đăng nhập Google thất bại: ${e.message ?? e.code}');
    }
  }
}
