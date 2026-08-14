import 'package:google_sign_in/google_sign_in.dart';
import 'package:event_app/core/constants/api_constants.dart';

/// Bọc google_sign_in (API v7: singleton + authenticate()) thành một
/// hàm đơn giản trả về Google idToken, để gửi lên backend
/// (POST /auth/google — xem GoogleAuthService.java).
class GoogleAuthHelper {
  final GoogleSignIn _signIn = GoogleSignIn.instance;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _signIn.initialize(
      serverClientId: ApiConstants.googleServerClientId,
    );
    _initialized = true;
  }

  /// Mở luồng đăng nhập Google, trả về idToken để verify ở backend.
  /// Trả về null nếu người dùng chủ động huỷ (không tính là lỗi).
  /// Ném Exception nếu Google Sign-In thất bại vì lý do khác.
  Future<String?> signInAndGetIdToken() async {
    await _ensureInitialized();
    try {
      final account = await _signIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw Exception('Google không trả về idToken, vui lòng thử lại');
      }
      return idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw Exception('Đăng nhập Google thất bại: ${e.description ?? e.code}');
    }
  }
}
