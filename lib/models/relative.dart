import 'package:event_app/models/event.dart';
import '../core/utils/relationship_emoji.dart';

class RelativeModel {
  final int id;
  final String name;
  final String? nickname;
  final String groupType;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? location;
  final List<String>? hobbies;
  final String? notes;
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
    this.hobbies,
    this.notes,
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
      hobbies: json['hobbies'] != null
          ? List<String>.from(json['hobbies'])
          : null,
      notes: json['notes'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      totalEvents: json['totalEvents'] as int?,
      // Backend (RelativeResponse.java) trả field tên "daysToBirthday",
      // không phải "daysUntilBirthday" — đọc sai key khiến đếm ngược sinh
      // nhật luôn null dù backend đã tính đúng.
      daysUntilBirthday: (json['daysToBirthday'] as num?)?.toInt(),
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
      'hobbies': hobbies,
      'notes': notes,
      'avatarUrl': avatarUrl,
    };
  }

  String get displayName => nickname ?? name;

  String get groupTypeDisplay {
    const map = {
      // Nhóm cũ — chỉ còn để hiển thị đúng cho người thân có sẵn.
      'GIA_DINH': 'Gia đình',
      'CON_CAI': 'Con cái',
      'BAN_BE': 'Bạn bè',
      // Danh sách quan hệ hiện dùng (khớp picker "Quan hệ với bạn").
      'BAN_THAN': 'Bản thân',
      'ONG': 'Ông',
      'BA': 'Bà',
      'BO': 'Bố',
      'ME': 'Mẹ',
      'VO_CHONG': 'Vợ (Chồng)',
      'ANH_CHI_EM': 'Anh/Chị/Em',
      'CON': 'Con Trai/Con Gái',
      'NGUOI_YEU': 'Người yêu',
      'NGUOI_THAN': 'Người Thân',
    };
    return map[groupType] ?? groupType;
  }

  /// Emoji đại diện quan hệ — khớp đúng bộ icon dùng ở picker "Quan hệ"
  /// (RelativeFormScreen._groupTypes) để avatar và picker luôn đồng nhất.
  String get groupTypeEmoji => emojiForGroupType(groupType);

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
  final List<String>? hobbies;
  final String? notes;
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
    this.hobbies,
    this.notes,
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
      hobbies: json['hobbies'] != null
          ? List<String>.from(json['hobbies'])
          : null,
      notes: json['notes'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      // Backend (RelativeDetailResponse.java) trả field tên "daysToBirthday",
      // không phải "daysUntilBirthday".
      daysUntilBirthday: (json['daysToBirthday'] as num?)?.toInt(),
      // Backend trả field tên "events" (RelativeDetailResponse.RelatedEventSummary:
      // id/title/categoryCode/eventDate/isActive — KHÔNG có categoryId/
      // categoryIcon/categoryColor/daysUntil như EventModel đầy đủ), không
      // phải "relatedEvents" — đọc sai key khiến màn chi tiết luôn hiện
      // "chưa có sự kiện nào" dù người thân đã có sự kiện liên kết.
      // daysUntil không có sẵn trong summary rút gọn này nên tự tính từ
      // eventDate để hiện đúng "Còn N ngày" như các màn khác.
      relatedEvents: json['events'] != null
          ? (json['events'] as List).map((e) {
              final map = Map<String, dynamic>.from(e as Map);
              final eventDate = DateTime.parse(map['eventDate'] as String);
              final today = DateTime.now();
              final todayDate = DateTime(today.year, today.month, today.day);
              return EventModel.fromJson({
                ...map,
                'daysUntil': eventDate.difference(todayDate).inDays,
              });
            }).toList()
          : [],
    );
  }

  String get displayName => nickname ?? name;

  String get groupTypeDisplay {
    const map = {
      // Nhóm cũ — chỉ còn để hiển thị đúng cho người thân có sẵn.
      'GIA_DINH': 'Gia đình',
      'CON_CAI': 'Con cái',
      'BAN_BE': 'Bạn bè',
      // Danh sách quan hệ hiện dùng (khớp picker "Quan hệ với bạn").
      'BAN_THAN': 'Bản thân',
      'ONG': 'Ông',
      'BA': 'Bà',
      'BO': 'Bố',
      'ME': 'Mẹ',
      'VO_CHONG': 'Vợ (Chồng)',
      'ANH_CHI_EM': 'Anh/Chị/Em',
      'CON': 'Con Trai/Con Gái',
      'NGUOI_YEU': 'Người yêu',
      'NGUOI_THAN': 'Người Thân',
    };
    return map[groupType] ?? groupType;
  }

  /// Emoji đại diện quan hệ — khớp đúng bộ icon dùng ở picker "Quan hệ"
  /// (RelativeFormScreen._groupTypes) để avatar và picker luôn đồng nhất.
  String get groupTypeEmoji => emojiForGroupType(groupType);

  String get genderDisplay {
    const map = {
      'MALE': 'Nam',
      'FEMALE': 'Nữ',
      'OTHER': 'Khác',
    };
    return map[gender] ?? '';
  }
}
