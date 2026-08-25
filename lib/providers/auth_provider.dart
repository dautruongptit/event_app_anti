import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_app/services/auth_service.dart';
import 'package:event_app/services/user_service.dart';
import 'package:event_app/services/google_auth_helper.dart';
import 'package:event_app/core/network/dio_client.dart';
import 'package:event_app/models/login_history.dart';
import 'package:event_app/models/user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final UserService _userService;
  final DioClient _dioClient;
  final GoogleAuthHelper _googleAuthHelper;

  AuthProvider(
    this._authService,
    this._userService,
    this._dioClient, [
    GoogleAuthHelper? googleAuthHelper,
  ]) : _googleAuthHelper = googleAuthHelper ?? GoogleAuthHelper();

  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;
  UserProfile? _user;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;
  UserProfile? get user => _user;

  Future<bool> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      if (token != null && token.isNotEmpty) {
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final authResponse = await _authService.login(email, password);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', authResponse.accessToken);
      await prefs.setString('refreshToken', authResponse.refreshToken);
      await prefs.setInt('userId', authResponse.id);

      _isAuthenticated = true;
      await _loadProfileSilently();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_extractErrorMessage(e));
      return false;
    }
  }

  /// Đăng nhập bằng Google. Trả về false + [error] == null nếu người dùng
  /// chủ động huỷ hộp thoại chọn tài khoản (không phải lỗi thật sự).
  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    try {
      final idToken = await _googleAuthHelper.signInAndGetIdToken();
      if (idToken == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final authResponse = await _authService.loginWithGoogle(idToken);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', authResponse.accessToken);
      await prefs.setString('refreshToken', authResponse.refreshToken);
      await prefs.setInt('userId', authResponse.id);

      _isAuthenticated = true;
      await _loadProfileSilently();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_extractErrorMessage(e));
      return false;
    }
  }

  Future<bool> register(String fullName, String email, String password) async {
    _setLoading(true);
    try {
      final authResponse = await _authService.register(fullName, email, password);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', authResponse.accessToken);
      await prefs.setString('refreshToken', authResponse.refreshToken);
      await prefs.setInt('userId', authResponse.id);

      _isAuthenticated = true;
      await _loadProfileSilently();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_extractErrorMessage(e));
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('userId');
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }

  Future<void> loadProfile() async {
    _setLoading(true);
    try {
      _user = await _userService.getProfile();
      _setLoading(false);
    } catch (e) {
      _setError(_extractErrorMessage(e));
    }
  }

  /// Tải profile ngay sau khi login/register/loginWithGoogle thành công, để
  /// Home có tên hiển thị ngay (tránh rơi về "Khách") mà không cần màn sau
  /// gọi loadProfile() riêng. Lỗi ở đây bị nuốt có chủ đích — accessToken
  /// đã lưu xong nên login vẫn tính là thành công dù bước này fail.
  Future<void> _loadProfileSilently() async {
    try {
      _user = await _userService.getProfile();
    } catch (_) {
      // Bỏ qua — không chặn luồng login đã thành công.
    }
  }

  Future<bool> updateProfile(String fullName) async {
    _setLoading(true);
    try {
      _user = await _authService.updateProfile(fullName);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_extractErrorMessage(e));
      return false;
    }
  }

  Future<bool> updateSettings({String? language, bool? darkMode}) async {
    _setLoading(true);
    try {
      _user = await _authService.updateSettings(
        language: language,
        darkMode: darkMode,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_extractErrorMessage(e));
      return false;
    }
  }

  Future<bool> uploadAvatar(File file) async {
    _setLoading(true);
    try {
      _user = await _authService.uploadAvatar(file);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(_extractErrorMessage(e));
      return false;
    }
  }

  /// Lấy lịch sử đăng nhập của chính mình (không đổi state loading chung
  /// của provider để không ảnh hưởng các màn khác đang lắng nghe).
  Future<List<LoginHistoryModel>> fetchLoginHistory({
    int page = 0,
    int size = 20,
  }) async {
    final result = await _authService.getLoginHistory(page: page, size: size);
    return result['content'] as List<LoginHistoryModel>;
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _error = null;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  String _extractErrorMessage(dynamic e) {
    if (e is Exception) {
      return e.toString().replaceFirst('Exception: ', '');
    }
    return e.toString();
  }
}
