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

/// Opens the bottom sheet for [tileLabel] ("Ngày"/"Tháng"/"Năm") and taps the
/// option labeled [optionLabel], scrolling the sheet's (lazily-built) list
/// until that option is actually on screen first.
Future<void> _pick(WidgetTester tester, String tileLabel, String optionLabel) async {
  await tester.tap(find.text(tileLabel));
  await tester.pumpAndSettle();
  final option = find.text(optionLabel);
  await tester.scrollUntilVisible(option, 150, scrollable: find.byType(Scrollable).last);
  await tester.pumpAndSettle();
  await tester.tap(option);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('picking day 29 then month 2 (no year yet) keeps day at 29, not clamped to 28', (tester) async {
    await tester.pumpWidget(await _buildApp());
    await tester.pumpAndSettle();

    await _pick(tester, 'Ngày', '29');
    await _pick(tester, 'Tháng', '2');

    // No year has been picked yet, so there is no real evidence this
    // February is non-leap — the day must still read 29.
    expect(find.text('29'), findsOneWidget);
    expect(find.text('28'), findsNothing);
  });

  testWidgets('day 29 + month 2 clamps to 28 once a non-leap year is picked', (tester) async {
    await tester.pumpWidget(await _buildApp());
    await tester.pumpAndSettle();
    final nonLeapYear = _nearestNonLeapYearAtOrBefore(DateTime.now().year);

    await _pick(tester, 'Ngày', '29');
    await _pick(tester, 'Tháng', '2');
    await _pick(tester, 'Năm', '$nonLeapYear');

    expect(find.text('28'), findsOneWidget);
    expect(find.text('29'), findsNothing);
  });

  testWidgets('day 29 + month 2 stays 29 when a leap year is picked', (tester) async {
    await tester.pumpWidget(await _buildApp());
    await tester.pumpAndSettle();
    final leapYear = _nearestLeapYearAtOrBefore(DateTime.now().year);

    await _pick(tester, 'Ngày', '29');
    await _pick(tester, 'Tháng', '2');
    await _pick(tester, 'Năm', '$leapYear');

    expect(find.text('29'), findsOneWidget);
  });
}
