import 'package:flutter/material.dart';

class EventModel {
  final int id;
  final String title;
  final int categoryId;
  final String categoryCode;
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;
  final DateTime eventDate;
  final String? eventTime;
  final int? lunarDay;
  final int? lunarMonth;
  final List<int>? participantIds;
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
    required this.categoryId,
    required this.categoryCode,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.eventDate,
    this.eventTime,
    this.lunarDay,
    this.lunarMonth,
    this.participantIds,
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
    final fallbackEventType = json['eventType'] as String?;
    
    // For backward compatibility, map old event types to names
    String defaultName = fallbackEventType ?? '';
    if (fallbackEventType != null && defaultName == fallbackEventType) {
      const oldNameMap = {
        'SINH_NHAT': 'Sinh nhật',
        'KY_NIEM': 'Kỷ niệm',
        'LE': 'Lễ',
        'NHA_O': 'Nhà ở',
        'HOA_DON': 'Hóa đơn',
        'MUA_SAM': 'Mua sắm',
        'KHAC': 'Khác',
      };
      defaultName = oldNameMap[fallbackEventType] ?? fallbackEventType;
    }

    return EventModel(
      id: json['id'] as int,
      title: json['title'] as String,
      categoryId: json['categoryId'] as int? ?? 0,
      categoryCode: json['categoryCode'] as String? ?? fallbackEventType ?? '',
      categoryName: json['categoryName'] as String? ?? defaultName,
      categoryIcon: json['categoryIcon'] as String? ?? '',
      categoryColor: json['categoryColor'] as String? ?? '',
      eventDate: DateTime.parse(json['eventDate'] as String),
      eventTime: json['eventTime'] as String?,
      lunarDay: json['lunarDay'] as int?,
      lunarMonth: json['lunarMonth'] as int?,
      participantIds: json['participantIds'] != null 
          ? List<int>.from(json['participantIds']) 
          : null,
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
      'categoryId': categoryId,
      'eventDate': eventDate.toIso8601String().split('T').first,
      'eventTime': eventTime,
      if (lunarDay != null) 'lunarDay': lunarDay,
      if (lunarMonth != null) 'lunarMonth': lunarMonth,
      if (participantIds != null) 'participantIds': participantIds,
      'isRecurring': isRecurring,
      'recurrenceType': recurrenceType,
      'notes': notes,
      'relativeId': relativeId,
      'reminders': reminders.map((r) => r.toJson()).toList(),
    };
  }

  String get eventTypeDisplay {
    return categoryName;
  }

  IconData get eventTypeIcon {
    final iconMap = {
      'cake': Icons.cake_rounded,
      'favorite': Icons.favorite_rounded,
      'celebration': Icons.celebration_rounded,
      'home': Icons.home_rounded,
      'receipt_long': Icons.receipt_long_rounded,
      'shopping_bag': Icons.shopping_bag_rounded,
      'event': Icons.event_rounded,
      'card_giftcard': Icons.card_giftcard_rounded,
      'bolt': Icons.bolt_rounded,
      'more_horiz': Icons.more_horiz_rounded,
    };
    
    if (categoryIcon.isNotEmpty && iconMap.containsKey(categoryIcon)) {
      return iconMap[categoryIcon]!;
    }
    
    // Fallback based on category code for backward compatibility
    const oldMap = {
      'SINH_NHAT': Icons.cake_rounded,
      'KY_NIEM': Icons.favorite_rounded,
      'LE': Icons.celebration_rounded,
      'NHA_O': Icons.home_rounded,
      'HOA_DON': Icons.receipt_long_rounded,
      'MUA_SAM': Icons.shopping_bag_rounded,
      'KHAC': Icons.event_rounded,
    };
    return oldMap[categoryCode] ?? Icons.event_rounded;
  }
  
  Color get categoryColorValue {
    if (categoryColor.isEmpty) return Colors.grey;
    String hexStr = categoryColor.replaceAll('#', '');
    if (hexStr.length == 6) {
      hexStr = 'FF$hexStr';
    }
    int? val = int.tryParse(hexStr, radix: 16);
    return val != null ? Color(val) : Colors.grey;
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
