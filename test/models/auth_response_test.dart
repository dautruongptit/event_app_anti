import 'package:flutter_test/flutter_test.dart';
import 'package:event_app/models/auth_response.dart';

void main() {
  group('AuthResponse.fromJson', () {
    test('đọc id từ field "userId" (đúng key backend trả về)', () {
      final json = {
        'userId': 42,
        'fullName': 'Nguyen Van A',
        'email': 'a@example.com',
        'accessToken': 'access-token',
        'refreshToken': 'refresh-token',
      };

      final result = AuthResponse.fromJson(json);

      expect(result.id, 42);
      expect(result.fullName, 'Nguyen Van A');
      expect(result.email, 'a@example.com');
      expect(result.accessToken, 'access-token');
      expect(result.refreshToken, 'refresh-token');
    });
  });
}
