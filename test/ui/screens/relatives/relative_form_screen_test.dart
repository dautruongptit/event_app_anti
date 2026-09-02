import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_app/core/network/dio_client.dart';
import 'package:event_app/providers/relative_provider.dart';
import 'package:event_app/services/relative_service.dart';
import 'package:event_app/ui/screens/relatives/relative_form_screen.dart';

/// Nearest year (at or before [from]) whose February has 29 days.
int _nearestLeapYearAtOrBefore(int from) {
  for (var y = from; y >= from - 8; y--) {
    if (DateUtils.getDaysInMonth(y, 2) == 29) return y;
  }
  throw StateError('no leap year found in range');
}

/// Nearest year (at or before [from]) whose February has 28 days.
int _nearestNonLeapYearAtOrBefore(int from) {
  for (var y = from; y >= from - 8; y--) {
    if (DateUtils.getDaysInMonth(y, 2) == 28) return y;
  }
  throw StateError('no non-leap year found in range');
}

Future<Widget> _buildApp() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final provider = RelativeProvider(RelativeService(DioClient(prefs)));
  return MaterialApp(
    home: ChangeNotifierProvider.value(
      value: provider,
      child: const RelativeFormScreen(),
    ),
  );
}

/// Taps [optionLabel] in the currently-open bottom option sheet, scrolling
/// its (lazily-built) list until the option is on screen first.
Future<void> _pickInOpenSheet(WidgetTester tester, String optionLabel) async {
  final option = find.text(optionLabel);
  await tester.scrollUntilVisible(option, 150,
      scrollable: find.byType(Scrollable).last);
  await tester.pumpAndSettle();
  await tester.tap(option);
  await tester.pumpAndSettle();
}

/// Drives the single "Ngày sinh" row through its sequential dd → mm → yyyy
/// sheet flow (tap the row once, each pick auto-advances to the next sheet
/// — matches the design's `pickDob`/`sheet:'dob'` chain). Pass `year: null`
/// to stop after month and dismiss the auto-opened year sheet via "Đóng",
/// leaving the date incomplete on purpose.
Future<void> _pickDobSequence(WidgetTester tester,
    {required int day, required int month, int? year}) async {
  await tester.tap(find.byKey(const Key('dobRow')));
  await tester.pumpAndSettle();
  await _pickInOpenSheet(tester, '$day');
  await _pickInOpenSheet(tester, '$month');
  if (year != null) {
    await _pickInOpenSheet(tester, '$year');
  } else {
    await tester.tap(find.text('Đóng'));
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets(
      'day 29 + month 2 clamps to 28 once a non-leap year is picked',
      (tester) async {
    await tester.pumpWidget(await _buildApp());
    await tester.pumpAndSettle();
    final nonLeapYear = _nearestNonLeapYearAtOrBefore(DateTime.now().year);

    await _pickDobSequence(tester, day: 29, month: 2, year: nonLeapYear);

    expect(find.text('28/02/$nonLeapYear'), findsOneWidget);
  });

  testWidgets('day 29 + month 2 stays 29 when a leap year is picked',
      (tester) async {
    await tester.pumpWidget(await _buildApp());
    await tester.pumpAndSettle();
    final leapYear = _nearestLeapYearAtOrBefore(DateTime.now().year);

    await _pickDobSequence(tester, day: 29, month: 2, year: leapYear);

    expect(find.text('29/02/$leapYear'), findsOneWidget);
  });

  testWidgets(
      'picking day 29 then month 2 without a year yet does not crash and leaves the date incomplete',
      (tester) async {
    await tester.pumpWidget(await _buildApp());
    await tester.pumpAndSettle();

    // No year chosen yet — nothing to base a leap-year clamp on, so the row
    // must still show the "not chosen" placeholder rather than crash or
    // silently commit a guessed date.
    await _pickDobSequence(tester, day: 29, month: 2);

    expect(find.text('Chọn ngày sinh'), findsOneWidget);
  });
}
