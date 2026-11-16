class ScreenTime {
  final int totalScreenTimeInSeconds;
  final DateTime date;
  final List<String> topApps;
  final Map<String, int> appUsage;

  ScreenTime({
    required this.totalScreenTimeInSeconds,
    required this.date,
    required this.topApps,
    required this.appUsage,
  });

  Map<String, dynamic> toJson() => {
    'totalScreenTimeInSeconds': totalScreenTimeInSeconds,
    'date': date.toIso8601String(),
    'topApps': topApps,
    'appUsage': appUsage,
  };

  factory ScreenTime.fromJson(Map<String, dynamic> json) => ScreenTime(
    totalScreenTimeInSeconds: json['totalScreenTimeInSeconds'] as int,
    date: DateTime.parse(json['date'] as String),
    topApps: List<String>.from(json['topApps'] as List),
    appUsage: Map<String, int>.from(json['appUsage'] as Map),
  );
} 