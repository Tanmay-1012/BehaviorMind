class Insight {
  final String id;
  final String date;
  final String title;
  final String description;
  final InsightType type;
  final bool isFollowed;

  Insight({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.type,
    this.isFollowed = false,
  });

  factory Insight.fromJson(Map<String, dynamic> json) {
    return Insight(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: InsightType.values.firstWhere(
        (t) => t.toString() == 'InsightType.${json['type']}',
        orElse: () => InsightType.behavior,
      ),
      isFollowed: json['isFollowed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'isFollowed': isFollowed,
    };
  }

  Insight copyWith({
    String? id,
    String? date,
    String? title,
    String? description,
    InsightType? type,
    bool? isFollowed,
  }) {
    return Insight(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }
}

enum InsightType {
  behavior,
  sleep,
  activity,
  mental,
  health,
}

extension InsightTypeExtension on InsightType {
  String get displayName {
    switch (this) {
      case InsightType.behavior:
        return 'Behavior';
      case InsightType.sleep:
        return 'Sleep';
      case InsightType.activity:
        return 'Activity';
      case InsightType.mental:
        return 'Mental';
      case InsightType.health:
        return 'Health';
    }
  }
}
