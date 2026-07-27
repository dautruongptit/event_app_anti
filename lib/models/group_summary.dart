class GroupSummary {
  final String groupType;
  final String displayName;
  final int count;

  const GroupSummary({
    required this.groupType,
    required this.displayName,
    required this.count,
  });

  factory GroupSummary.fromJson(Map<String, dynamic> json) {
    return GroupSummary(
      groupType: json['groupType'] as String,
      displayName: json['displayName'] as String? ?? json['groupType'] as String,
      count: json['count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupType': groupType,
      'displayName': displayName,
      'count': count,
    };
  }
}
