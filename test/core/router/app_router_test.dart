import 'package:flutter_test/flutter_test.dart';
import 'package:event_app/core/router/app_router.dart';

void main() {
  group('decideRedirect', () {
    test('logged in + splash -> /home (session cũ khôi phục không kẹt màn splash)', () {
      expect(decideRedirect(isLoggedIn: true, matchedLocation: '/splash'), '/home');
    });

    test('logged in + login -> /home', () {
      expect(decideRedirect(isLoggedIn: true, matchedLocation: '/login'), '/home');
    });

    test('logged in + register -> /home', () {
      expect(decideRedirect(isLoggedIn: true, matchedLocation: '/register'), '/home');
    });

    test('logged in + any other route -> no redirect', () {
      expect(decideRedirect(isLoggedIn: true, matchedLocation: '/home'), isNull);
      expect(decideRedirect(isLoggedIn: true, matchedLocation: '/events'), isNull);
    });

    test('not logged in + splash -> no redirect (chưa có evidence để đá về login)', () {
      expect(decideRedirect(isLoggedIn: false, matchedLocation: '/splash'), isNull);
    });

    test('not logged in + login/register -> no redirect', () {
      expect(decideRedirect(isLoggedIn: false, matchedLocation: '/login'), isNull);
      expect(decideRedirect(isLoggedIn: false, matchedLocation: '/register'), isNull);
    });

    test('not logged in + protected route -> /login', () {
      expect(decideRedirect(isLoggedIn: false, matchedLocation: '/home'), '/login');
      expect(decideRedirect(isLoggedIn: false, matchedLocation: '/events'), '/login');
    });
  });
}
