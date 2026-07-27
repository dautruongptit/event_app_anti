import 'package:flutter/material.dart';

class EventModel {
  final int id;
  final String title;
  final String eventType;
  final DateTime eventDate;
  final String? eventTime;
  final bool isRecurring;
  final String? recurrenceType;
  final String? notes;
  final int? relativeId;
  final String? relativeName;
  final String? relativeGroupType;
  final int? daysUntil;
  final List<ReminderModel> reminders;

  const EventModel({
    required this.id,
    required this.title,
    required this.eventType,
    required this.eventDate,
    this.eventTime,
    this.isRecurring = false,
    this.recurrenceType,
    this.notes,
    this.relativeId,
    this.relativeName,
    this.relativeGroupType,
    this.daysUntil,
    this.reminders = const [],
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as int,
      title: json['title'] as String,
      eventType: json['eventType'] as String,
      eventDate: DateTime.parse(json['eventDate'] as String),
      eventTime: json['eventTime'] as String?,
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurrenceType: json['recurrenceType'] as String?,
      notes: json['notes'] as String?,
      relativeId: json['relativeId'] as int?,
      relativeName: json['relativeName'] as String?,
      relativeGroupType: json['relativeGroupType'] as String?,
      daysUntil: json['daysUntil'] as int?,
      reminders: json['reminders'] != null
          ? (json['reminders'] as List)
              .map((r) => ReminderModel.fromJson(r))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'eventType': eventType,
      'eventDate': eventDate.toIso8601String().split('T').first,
      'eventTime': eventTime,
      'isRecurring': isRecurring,
      'recurrenceType': recurrenceType,
      'notes': notes,
      'relativeId': relativeId,
      'reminders': reminders.map((r) => r.toJson()).toList(),
    };
  }

  String get eventTypeDisplay {
    const map = {
      'SINH_NHAT': 'Sinh nhật',
      'KY_NIEM': 'Kỷ niệm',
      'LE': 'Lễ',
      'NHA_O': 'Nhà ở',
      'HOA_DON': 'Hóa đơn',
      'MUA_SAM': 'Mua sắm',
      'KHAC': 'Khác',
    };
    return map[eventType] ?? eventType;
  }

  IconData get eventTypeIcon {
    const map = {
      'SINH_NHAT': Icons.cake_rounded,
      'KY_NIEM': Icons.favorite_rounded,
      'LE': Icons.celebration_rounded,
      'NHA_O': Icons.home_rounded,
      'HOA_DON': Icons.receipt_long_rounded,
      'MUA_SAM': Icons.shopping_bag_rounded,
      'KHAC': Icons.event_rounded,
    };
    return map[eventType] ?? Icons.event_rounded;
  }

  bool get isPast => eventDate.isBefore(DateTime.now());

  String get daysUntilText {
    if (daysUntil == null || daysUntil! < 0) return '';
    if (daysUntil == 0) return 'Hôm nay';
    if (daysUntil == 1) return 'Ngày mai';
    return 'Còn $daysUntil ngày';
  }
}

class ReminderModel {
  final int? id;
  final int? remindDaysBefore;
  final int? remindHoursBefore;
  final bool isEnabled;

  const ReminderModel({
    this.id,
    this.remindDaysBefore,
    this.remindHoursBefore,
    this.isEnabled = true,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as int?,
      remindDaysBefore: json['remindDaysBefore'] as int?,
      remindHoursBefore: json['remindHoursBefore'] as int?,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'remindDaysBefore': remindDaysBefore,
      'remindHoursBefore': remindHoursBefore,
      'isEnabled': isEnabled,
    };
  }

  String get displayText {
    if (remindDaysBefore != null && remindDaysBefore! > 0) {
      return 'Trước $remindDaysBefore ngày';
    }
    if (remindHoursBefore != null && remindHoursBefore! > 0) {
      return 'Trước $remindHoursBefore giờ';
    }
    return 'Ngay lúc sự kiện';
  }
}
