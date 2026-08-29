import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_app/ui/screens/holidays/holiday_screen.dart';

void main() {
  testWidgets('HolidayScreen renders the current-year summary without throwing', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: HolidayScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Lịch nghỉ lễ'), findsOneWidget);
    expect(find.text('Tết Nguyên Đán'), findsOneWidget);
  });
}
