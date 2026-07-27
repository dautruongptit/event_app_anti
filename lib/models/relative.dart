import 'package:event_app/models/event.dart';

class RelativeModel {
  final int id;
  final String name;
  final String? nickname;
  final String groupType;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? location;
  final double? heightCm;
  final double? weightKg;
  final List<String>? hobbies;
  final String? avatarUrl;
  final int? totalEvents;
  final int? daysUntilBirthday;
  final String? nextEventTitle;

  const RelativeModel({
    required this.id,
    required this.name,
    this.nickname,
    required this.groupType,
    this.gender,
    this.dateOfBirth,
    this.location,
    this.heightCm,
    this.weightKg,
    this.hobbies,
    this.avatarUrl,
    this.totalEvents,
    this.daysUntilBirthday,
    this.nextEventTitle,
  });

  factory RelativeModel.fromJson(Map<String, dynamic> json) {
    return RelativeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      nickname: json['nickname'] as String?,
      groupType: json['groupType'] as String,
      gender: json['gender'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'])
          : null,
      location: json['location'] as String?,
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      hobbies: json['hobbies'] != null
          ? List<String>.from(json['hobbies'])
          : null,
      avatarUrl: json['avatarUrl'] as String?,
      totalEvents: json['totalEvents'] as int?,
      daysUntilBirthday: json['daysUntilBirthday'] as int?,
      nextEventTitle: json['nextEventTitle'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nickname': nickname,
      'groupType': groupType,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String().split('T').first,
      'location': location,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'hobbies': hobbies,
      'avatarUrl': avatarUrl,
    };
  }

  String get displayName => nickname ?? name;

  String get groupTypeDisplay {
    const map = {
      'GIA_DINH': 'Gia đình',
      'VO_CHONG': 'Vợ/Chồng',
      'CON_CAI': 'Con cái',
      'BAN_BE': 'Bạn bè',
    };
    return map[groupType] ?? groupType;
  }

  String get genderDisplay {
    const map = {
      'MALE': 'Nam',
      'FEMALE': 'Nữ',
      'OTHER': 'Khác',
    };
    return map[gender] ?? '';
  }

  String get birthdayText {
    if (daysUntilBirthday == null || daysUntilBirthday! < 0) return '';
    if (daysUntilBirthday == 0) return 'Sinh nhật hôm nay! 🎂';
    if (daysUntilBirthday == 1) return 'Sinh nhật ngày mai 🎂';
    return 'Còn $daysUntilBirthday ngày đến sinh nhật';
  }
}

class RelativeDetailModel {
  final int id;
  final String name;
  final String? nickname;
  final String groupType;
  final String? gender;
  final int? age;
  final DateTime? dateOfBirth;
  final String? location;
  final double? heightCm;
  final double? weightKg;
  final List<String>? hobbies;
  final String? avatarUrl;
  final int? daysUntilBirthday;
  final List<EventModel> relatedEvents;

  const RelativeDetailModel({
    required this.id,
    required this.name,
    this.nickname,
    required this.groupType,
    this.gender,
    this.age,
    this.dateOfBirth,
    this.location,
    this.heightCm,
    this.weightKg,
    this.hobbies,
    this.avatarUrl,
    this.daysUntilBirthday,
    this.relatedEvents = const [],
  });

  factory RelativeDetailModel.fromJson(Map<String, dynamic> json) {
    return RelativeDetailModel(
      id: json['id'] as int,
      name: json['name'] as String,
      nickname: json['nickname'] as String?,
      groupType: json['groupType'] as String,
      gender: json['gender'] as String?,
      age: json['age'] as int?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'])
          : null,
      location: json['location'] as String?,
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      hobbies: json['hobbies'] != null
          ? List<String>.from(json['hobbies'])
          : null,
      avatarUrl: json['avatarUrl'] as String?,
      daysUntilBirthday: json['daysUntilBirthday'] as int?,
      relatedEvents: json['relatedEvents'] != null
          ? (json['relatedEvents'] as List)
              .map((e) => EventModel.fromJson(e))
              .toList()
          : [],
    );
  }

  String get displayName => nickname ?? name;

  String get groupTypeDisplay {
    const map = {
      'GIA_DINH': 'Gia đình',
      'VO_CHONG': 'Vợ/Chồng',
      'CON_CAI': 'Con cái',
      'BAN_BE': 'Bạn bè',
    };
    return map[groupType] ?? groupType;
  }

  String get genderDisplay {
    const map = {
      'MALE': 'Nam',
      'FEMALE': 'Nữ',
      'OTHER': 'Khác',
    };
    return map[gender] ?? '';
  }
}
