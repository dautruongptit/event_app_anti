import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_app/core/network/dio_client.dart';
import 'package:event_app/models/event.dart';
import 'package:event_app/providers/event_provider.dart';
import 'package:event_app/services/event_service.dart';
import 'package:event_app/ui/screens/events/event_detail_screen.dart';

/// Stubs network calls so the test never hits a real backend, and lets a
/// test set a fixture event directly instead of waiting on a real load.
class _FakeEventProvider extends EventProvider {
  _FakeEventProvider(super.service);

  EventModel? fixtureEvent;
  int? deletedEventId;
  bool deleteResult = true;

  @override
  EventModel? get selectedEvent => fixtureEvent;

  @override
  Future<void> loadEventById(int id) async {}

  @override
  Future<bool> deleteEvent(int id) async {
    deletedEventId = id;
    if (deleteResult) fixtureEvent = null;
    notifyListeners();
    return deleteResult;
  }
}

Future<SharedPreferences> _fakePrefs() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

EventModel _weddingAnniversary({
  String? relativeName,
  String? relativeGroupType,
  int? relativeId,
  String? eventTime,
  bool isRecurring = true,
  String? recurrenceType = 'YEARLY',
  String? notes,
  List<ReminderModel> reminders = const [ReminderModel(remindDaysBefore: 1)],
  int? daysUntil = 0,
}) {
  return EventModel(
    id: 42,
    title: 'Kỷ niệm ngày cưới',
    categoryId: 1,
    categoryCode: 'KY_NIEM',
    categoryName: 'Cá nhân',
    categoryIcon: 'favorite',
    categoryColor: '#FF5A5F',
    eventDate: DateTime(2026, 9, 4),
    eventTime: eventTime,
    isRecurring: isRecurring,
    recurrenceType: recurrenceType,
    notes: notes,
    relativeId: relativeId,
    relativeName: relativeName,
    relativeGroupType: relativeGroupType,
    daysUntil: daysUntil,
    reminders: reminders,
  );
}

Future<Widget> _buildApp({required GoRouter router, required _FakeEventProvider eventProvider}) async {
  final prefs = await _fakePrefs();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<EventProvider>.value(value: eventProvider),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

GoRouter _detailRouter() {
  return GoRouter(
    initialLocation: '/events/42',
    routes: [
      GoRoute(path: '/events', builder: (context, state) => const Text('EVENTS_LIST_SCREEN')),
      GoRoute(
        path: '/events/:id',
        builder: (context, state) => const EventDetailScreen(eventId: 42),
        routes: [
          GoRoute(path: 'edit', builder: (context, state) => const Text('EVENT_EDIT_SCREEN')),
        ],
      ),
    ],
  );
}

void main() {
  testWidgets('shows category, date, time, recurrence and reminder rows for a self event', (tester) async {
    final provider = _FakeEventProvider(EventService(DioClient(await _fakePrefs())));
    provider.fixtureEvent = _weddingAnniversary(eventTime: '08:00');

    await tester.pumpWidget(await _buildApp(router: _detailRouter(), eventProvider: provider));
    await tester.pumpAndSettle();

    expect(find.text('Kỷ niệm ngày cưới'), findsOneWidget);
    expect(find.text('Cá nhân'), findsOneWidget);
    expect(find.text('Không có'), findsOneWidget); // Người thân — sự kiện cho bản thân
    expect(find.text('Hôm nay'), findsWidgets); // header days-label + row "Ngày"
    expect(find.text('08:00'), findsOneWidget);
    expect(find.text('Hàng năm'), findsOneWidget);
    expect(find.text('Trước 1 ngày'), findsOneWidget);
    expect(find.text('Chưa có ghi chú'), findsOneWidget);
  });

  testWidgets('shows relative name, "Cả ngày" and "Không lặp" when the event has none of those', (tester) async {
    final provider = _FakeEventProvider(EventService(DioClient(await _fakePrefs())));
    provider.fixtureEvent = _weddingAnniversary(
      relativeName: 'Nguyễn Thị B',
      relativeGroupType: 'ME',
      relativeId: 7,
      eventTime: null,
      isRecurring: false,
      recurrenceType: null,
      reminders: const [],
      notes: 'Đặt hoa trước 1 ngày',
      daysUntil: 5,
    );

    await tester.pumpWidget(await _buildApp(router: _detailRouter(), eventProvider: provider));
    await tester.pumpAndSettle();

    expect(find.text('Nguyễn Thị B'), findsOneWidget);
    expect(find.text('Cả ngày'), findsOneWidget);
    expect(find.text('Không lặp'), findsOneWidget);
    expect(find.text('Không có'), findsOneWidget); // Nhắc nhở — danh sách rỗng
    expect(find.text('Đặt hoa trước 1 ngày'), findsOneWidget);
  });

  testWidgets('tapping "Sửa" navigates to the edit route', (tester) async {
    final provider = _FakeEventProvider(EventService(DioClient(await _fakePrefs())));
    provider.fixtureEvent = _weddingAnniversary();

    await tester.pumpWidget(await _buildApp(router: _detailRouter(), eventProvider: provider));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sửa'));
    await tester.pumpAndSettle();

    expect(find.text('EVENT_EDIT_SCREEN'), findsOneWidget);
  });

  testWidgets('deleting the event shows a confirm sheet, then pops back to the list on success', (tester) async {
    final provider = _FakeEventProvider(EventService(DioClient(await _fakePrefs())));
    provider.fixtureEvent = _weddingAnniversary();

    final router = GoRouter(
      initialLocation: '/events',
      routes: [
        GoRoute(path: '/events', builder: (context, state) => const Text('EVENTS_LIST_SCREEN')),
        GoRoute(path: '/events/:id', builder: (context, state) => const EventDetailScreen(eventId: 42)),
      ],
    );
    await tester.pumpWidget(await _buildApp(router: router, eventProvider: provider));
    await tester.pumpAndSettle();
    router.push('/events/42');
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pumpAndSettle();

    // Confirm sheet is up, deleteEvent has not been called yet.
    expect(find.text('Xoá sự kiện này?'), findsOneWidget);
    expect(provider.deletedEventId, isNull);

    await tester.tap(find.text('Xoá'));
    await tester.pumpAndSettle();

    expect(provider.deletedEventId, 42);
    expect(find.text('EVENTS_LIST_SCREEN'), findsOneWidget);

    // showNinoToast schedules a Future.delayed to auto-dismiss — let it
    // fire so no pending timer trips the test framework's invariant check.
    await tester.pump(const Duration(milliseconds: 2000));
  });
}
