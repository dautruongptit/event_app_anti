import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_app/core/network/dio_client.dart';
import 'package:event_app/providers/auth_provider.dart';
import 'package:event_app/services/auth_service.dart';
import 'package:event_app/services/google_auth_helper.dart';
import 'package:event_app/services/user_service.dart';

/// Không gọi API logout thật (không có backend trong test).
class _FakeAuthService extends AuthService {
  _FakeAuthService(super.dio);

  @override
  Future<void> logout() async {}
}

/// Theo dõi xem AuthProvider.logout() có xoá phiên Google Sign-In đã cache
/// hay không — đây là điều kiện để lần đăng nhập Google kế tiếp hiện lại
/// hộp thoại chọn tài khoản thay vì tự động dùng lại tài khoản cũ.
class _FakeGoogleAuthHelper extends GoogleAuthHelper {
  bool signOutCalled = false;

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }
}

void main() {
  late AuthProvider provider;
  late _FakeGoogleAuthHelper fakeGoogleAuthHelper;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'accessToken': 'fake-token',
      'refreshToken': 'fake-refresh',
      'userId': 1,
    });
    final prefs = await SharedPreferences.getInstance();
    final dioClient = DioClient(prefs);
    fakeGoogleAuthHelper = _FakeGoogleAuthHelper();
    provider = AuthProvider(
      _FakeAuthService(dioClient),
      UserService(dioClient),
      dioClient,
      fakeGoogleAuthHelper,
    );
  });

  test('logout() signs out of Google too, so the account picker shows again on the next Google login', () async {
    await provider.logout();

    expect(fakeGoogleAuthHelper.signOutCalled, isTrue);
  });
}
