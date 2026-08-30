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

  /// Set by a test to simulate loadEventById() finding an existing event
  /// with specific reminders — null (default) matches the "add new event"
  /// flow the other tests exercise.
  EventModel? fixtureEvent;

  /// Captures the exact map passed to updateEvent(), so a test can assert
  /// on it (e.g. that reminders were not silently dropped).
  Map<String, dynamic>? lastUpdatePayload;

  @override
  EventModel? get selectedEvent => fixtureEvent;

  @override
  Future<void> loadEventById(int id) async {}

  @override
  Future<bool> createEvent(Map<String, dynamic> data) async => true;

  @override
  Future<bool> updateEvent(int id, Map<String, dynamic> data) async {
    lastUpdatePayload = data;
    return true;
  }
}

/// initState unconditionally calls loadRelatives() — stub it so no real
/// network call happens during the test.
class _FakeRelativeProvider extends RelativeProvider {
  _FakeRelativeProvider(super.service);

  @override
  Future<void> loadRelatives() async {}
}

Future<SharedPreferences> _fakePrefs() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

Future<Widget> _buildApp({required GoRouter router, _FakeEventProvider? eventProvider}) async {
  final prefs = await _fakePrefs();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<EventProvider>.value(
        value: eventProvider ?? _FakeEventProvider(EventService(DioClient(prefs))),
      ),
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

  testWidgets('editing an event with a custom repeat-interval reminder preserves it on save untouched', (tester) async {
    // Reproduces the real "Uống thuốc" (medicine reminder) bug: the event
    // has a reminder shaped like "every 30 minutes until read"
    // (remindHoursBefore:0, repeatIntervalMinutes:30) that none of the 4
    // standard preset checks recognize. Opening the edit form and saving
    // without touching the reminders section must not silently wipe it.
    final fakeEventProvider = _FakeEventProvider(EventService(DioClient(await _fakePrefs())));
    fakeEventProvider.fixtureEvent = EventModel(
      id: 15,
      title: 'Uống thuốc',
      categoryId: 7,
      categoryCode: 'KHAC',
      categoryName: 'Khác',
      categoryIcon: 'more_horiz',
      categoryColor: '#95A5A6',
      eventDate: DateTime(2026, 8, 30),
      eventTime: '13:35',
      isRecurring: true,
      recurrenceType: 'YEARLY',
      relativeId: 7,
      reminders: const [
        ReminderModel(id: 58, remindHoursBefore: 0, repeatIntervalMinutes: 30, isEnabled: true),
      ],
    );

    final router = GoRouter(
      initialLocation: '/events',
      routes: [
        GoRoute(path: '/events', builder: (context, state) => const Text('EVENTS_LIST_SCREEN')),
        GoRoute(
          path: '/events/:id',
          builder: (context, state) => const Text('EVENT_DETAIL_SCREEN'),
          routes: [
            GoRoute(path: 'edit', builder: (context, state) => const EventFormScreen(eventId: 15)),
          ],
        ),
      ],
    );
    await tester.pumpWidget(await _buildApp(router: router, eventProvider: fakeEventProvider));
    await tester.pumpAndSettle();

    router.push('/events/15');
    await tester.pumpAndSettle();
    router.push('/events/15/edit');
    await tester.pumpAndSettle();

    // The custom reminder must render as a visible, removable chip — not
    // silently disappear from the UI while still (invisibly) surviving.
    expect(find.textContaining('30 phút'), findsOneWidget);

    // Save WITHOUT touching the reminders section at all.
    await tester.tap(find.text('Lưu').first);
    await tester.pumpAndSettle();

    final sentReminders = fakeEventProvider.lastUpdatePayload!['reminders'] as List;
    expect(
      sentReminders.any((r) => r['repeatIntervalMinutes'] == 30 && r['remindHoursBefore'] == 0),
      isTrue,
      reason: 'the repeat-interval reminder must survive an edit+save that never touched reminders, got: $sentReminders',
    );
  });
}
