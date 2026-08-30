import 'package:flutter_test/flutter_test.dart';
import 'package:event_app/models/relative.dart';

void main() {
  group('RelativeModel.fromJson', () {
    test('reads the backend\'s actual key "daysToBirthday" (not "daysUntilBirthday")', () {
      final json = {
        'id': 6,
        'name': 'Nguyen Van Me',
        'groupType': 'GIA_DINH',
        'daysToBirthday': 258,
      };

      final relative = RelativeModel.fromJson(json);

      expect(relative.daysUntilBirthday, 258);
    });
  });

  group('RelativeDetailModel.fromJson', () {
    test('reads "daysToBirthday" for the birthday countdown', () {
      final json = {
        'id': 7,
        'name': 'Người yêu',
        'groupType': 'VO_CHONG',
        'daysToBirthday': 21,
      };

      final relative = RelativeDetailModel.fromJson(json);

      expect(relative.daysUntilBirthday, 21);
    });

    test('reads the backend\'s actual key "events" (not "relatedEvents") for linked events', () {
      final json = {
        'id': 7,
        'name': 'Người yêu',
        'groupType': 'VO_CHONG',
        'totalEvents': 3,
        'events': [
          {'id': 16, 'title': 'Kỷ niệm ngày yêu nhau', 'categoryCode': 'KY_NIEM', 'eventDate': '2026-09-05', 'isActive': true},
          {'id': 20, 'title': 'Sự kiện đáng nhớ', 'categoryCode': 'KY_NIEM', 'eventDate': '2026-09-12', 'isActive': true},
          {'id': 17, 'title': 'Sinh nhật người yêu', 'categoryCode': 'SINH_NHAT', 'eventDate': '2026-09-20', 'isActive': true},
        ],
      };

      final relative = RelativeDetailModel.fromJson(json);

      expect(relative.relatedEvents.length, 3);
      expect(relative.relatedEvents[0].id, 16);
      expect(relative.relatedEvents[0].title, 'Kỷ niệm ngày yêu nhau');
      expect(relative.relatedEvents[1].title, 'Sự kiện đáng nhớ');
      expect(relative.relatedEvents[2].title, 'Sinh nhật người yêu');
    });

    test('computes daysUntil for each linked event from its eventDate (backend summary omits it)', () {
      final in5Days = DateTime.now().add(const Duration(days: 5));
      final eventDateStr =
          '${in5Days.year.toString().padLeft(4, '0')}-${in5Days.month.toString().padLeft(2, '0')}-${in5Days.day.toString().padLeft(2, '0')}';
      final json = {
        'id': 7,
        'name': 'Người yêu',
        'groupType': 'VO_CHONG',
        'events': [
          {'id': 20, 'title': 'Sự kiện đáng nhớ', 'categoryCode': 'KY_NIEM', 'eventDate': eventDateStr, 'isActive': true},
        ],
      };

      final relative = RelativeDetailModel.fromJson(json);

      expect(relative.relatedEvents[0].daysUntil, 5);
    });

    test('no events -> empty relatedEvents, no crash', () {
      final json = {'id': 7, 'name': 'Người yêu', 'groupType': 'VO_CHONG'};

      final relative = RelativeDetailModel.fromJson(json);

      expect(relative.relatedEvents, isEmpty);
    });
  });
}
