import 'package:event_app/models/event.dart';
import 'package:event_app/models/relative.dart';

class HomeResponse {
  final String userName;
  final String? avatarUrl;
  final List<EventModel> upcomingEvents;
  final List<RelativeModel> relatives;
  final List<EventModel> myEvents;
  final bool? googleCalendarConnected;

  const HomeResponse({
    required this.userName,
    this.avatarUrl,
    this.upcomingEvents = const [],
    this.relatives = const [],
    this.myEvents = const [],
    this.googleCalendarConnected,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      userName: json['userName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      upcomingEvents: json['upcomingEvents'] != null
          ? (json['upcomingEvents'] as List)
              .map((e) => EventModel.fromJson(e))
              .toList()
          : [],
      relatives: json['relatives'] != null
          ? (json['relatives'] as List)
              .map((e) => RelativeModel.fromJson(e))
              .toList()
          : [],
      myEvents: json['myEvents'] != null
          ? (json['myEvents'] as List)
              .map((e) => EventModel.fromJson(e))
              .toList()
          : [],
      googleCalendarConnected: json['googleCalendarConnected'] as bool?,
    );
  }
}
