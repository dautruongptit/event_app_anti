import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_app/core/network/dio_client.dart';
import 'package:event_app/models/event.dart';
import 'package:event_app/providers/event_provider.dart';
import 'package:event_app/providers/relative_provider.dart';
import 'package:event_app/services/event_service.dart';
import 'package:event_app/services/relative_service.dart';
import 'package:event_app/ui/screens/events/event_form_screen.dart';

/// Stubs out the network calls so the test never hits a real backend —
/// mirrors exactly what the real provider does on success (returns true)
/// without touching `_eventService`.
class _FakeEventProvider extends EventProvider {
  _FakeEventProvider(super.service);

  @override
  EventModel? get selectedEvent => null;

  @override
  Future<void> loadEventById(int id) async {}

  @override
  Future<bool> createEvent(Map<String, dynamic> data) async => true;

  @override
  Future<bool> updateEvent(int id, Map<String, dynamic> data) async => true;
}

/// initState unconditionally calls loadRelatives() — stub it so no real
/// network call happens during the test.
class _FakeRelativeProvider extends RelativeProvider {
  _FakeRelativeProvider(super.service);

  @override
  Future<void> loadRelatives() async {}
}

Future<Widget> _buildApp({required GoRouter router}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<EventProvider>(create: (_) => _FakeEventProvider(EventService(DioClient(prefs)))),
      ChangeNotifierProvider<RelativeProvider>(create: (_) => _FakeRelativeProvider(RelativeService(DioClient(prefs)))),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('saving a new event navigates to the Events screen, not just one level back', (tester) async {
    final router = GoRouter(
      initialLocation: '/events',
      routes: [
        GoRoute(path: '/events', builder: (context, state) => const Text('EVENTS_LIST_SCREEN')),
        GoRoute(
          path: '/events/new',
          builder: (context, state) => const Text('TYPE_SELECTION_SCREEN'),
          routes: [
            GoRoute(path: 'form', builder: (context, state) => const EventFormScreen()),
          ],
        ),
      ],
    );
    await tester.pumpWidget(await _buildApp(router: router));
    await tester.pumpAndSettle();

    // Simulate the real navigation depth: List -> Type selection -> Form
    // (an intermediate screen a plain context.pop() would land back on).
    router.push('/events/new');
    await tester.pumpAndSettle();
    router.push('/events/new/form');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Sự kiện test');
    await tester.tap(find.text('Lưu').first);
    await tester.pumpAndSettle();

    expect(find.text('EVENTS_LIST_SCREEN'), findsOneWidget);
    expect(find.text('TYPE_SELECTION_SCREEN'), findsNothing);
  });

  testWidgets('saving an edited event navigates to the Events screen, not the detail screen', (tester) async {
    final router = GoRouter(
      initialLocation: '/events',
      routes: [
        GoRoute(path: '/events', builder: (context, state) => const Text('EVENTS_LIST_SCREEN')),
        GoRoute(
          path: '/events/:id',
          builder: (context, state) => const Text('EVENT_DETAIL_SCREEN'),
          routes: [
            GoRoute(path: 'edit', builder: (context, state) => const EventFormScreen(eventId: 1)),
          ],
        ),
      ],
    );
    await tester.pumpWidget(await _buildApp(router: router));
    await tester.pumpAndSettle();

    router.push('/events/1');
    await tester.pumpAndSettle();
    router.push('/events/1/edit');
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Sự kiện đã sửa');
    await tester.tap(find.text('Lưu').first);
    await tester.pumpAndSettle();

    expect(find.text('EVENTS_LIST_SCREEN'), findsOneWidget);
    expect(find.text('EVENT_DETAIL_SCREEN'), findsNothing);
  });
}
