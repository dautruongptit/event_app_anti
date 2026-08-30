import 'package:flutter_test/flutter_test.dart';
import 'package:event_app/models/event.dart';

void main() {
  group('ReminderModel.fromJson', () {
    test('reads repeatIntervalMinutes (repeat-until-read reminders, e.g. "nhắc uống thuốc mỗi 30 phút")', () {
      final json = {
        'id': 58,
        'remindDaysBefore': null,
        'remindHoursBefore': 0,
        'repeatIntervalMinutes': 30,
        'isEnabled': true,
      };

      final reminder = ReminderModel.fromJson(json);

      expect(reminder.repeatIntervalMinutes, 30);
      expect(reminder.remindHoursBefore, 0);
    });

    test('repeatIntervalMinutes defaults to null for standard (non-repeating) reminders', () {
      final json = {'id': 1, 'remindDaysBefore': 7, 'isEnabled': true};

      final reminder = ReminderModel.fromJson(json);

      expect(reminder.repeatIntervalMinutes, isNull);
    });
  });
}
