import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix3;
import 'package:event_app/ui/widgets/nino/shake_on_change.dart';

Transform _findTransform(WidgetTester tester) =>
    tester.widget<Transform>(find.byType(Transform));

void main() {
  testWidgets('renders the child with no rotation before the trigger ever changes', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ShakeOnChange(trigger: 0, child: const Icon(Icons.notifications_none_rounded)),
    ));

    expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    expect(_findTransform(tester).transform.getRotation(), Matrix3.identity());
  });

  testWidgets('rotates away from 0 mid-animation once trigger changes, then settles back to 0', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ShakeOnChange(trigger: 0, child: const Icon(Icons.notifications_none_rounded)),
    ));

    await tester.pumpWidget(MaterialApp(
      home: ShakeOnChange(trigger: 1, child: const Icon(Icons.notifications_none_rounded)),
    ));
    await tester.pump(const Duration(milliseconds: 150));

    final midRotation = _findTransform(tester).transform.getRotation();
    expect(midRotation, isNot(Matrix3.identity()));

    await tester.pumpAndSettle();
    final endRotation = _findTransform(tester).transform.getRotation();
    expect(endRotation.getColumn(0)[0], closeTo(1.0, 0.001));
  });

  testWidgets('does not re-shake on a rebuild where trigger stays the same', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ShakeOnChange(trigger: 5, child: const Icon(Icons.notifications_none_rounded)),
    ));
    await tester.pumpAndSettle();

    // Rebuild with the identical trigger value (e.g. parent rebuilt for an
    // unrelated reason) — must not restart the shake.
    await tester.pumpWidget(MaterialApp(
      home: ShakeOnChange(trigger: 5, child: const Icon(Icons.notifications_active_rounded)),
    ));
    await tester.pump(const Duration(milliseconds: 50));

    expect(_findTransform(tester).transform.getRotation(), Matrix3.identity());
  });
}
