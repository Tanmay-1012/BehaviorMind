class AppUsage {
  final String packageName;
  final String? appName;
  final int durationInSeconds;
  final DateTime firstTimeStamp;
  final DateTime lastTimeStamp;

  AppUsage({
    required this.packageName,
    this.appName,
    required this.durationInSeconds,
    required this.firstTimeStamp,
    required this.lastTimeStamp,
  });

  Map<String, dynamic> toJson() => {
    'packageName': packageName,
    'appName': appName,
    'durationInSeconds': durationInSeconds,
    'firstTimeStamp': firstTimeStamp.toIso8601String(),
    'lastTimeStamp': lastTimeStamp.toIso8601String(),
  };

  factory AppUsage.fromJson(Map<String, dynamic> json) => AppUsage(
    packageName: json['packageName'] as String,
    appName: json['appName'] as String?,
    durationInSeconds: json['durationInSeconds'] as int,
    firstTimeStamp: DateTime.parse(json['firstTimeStamp'] as String),
    lastTimeStamp: DateTime.parse(json['lastTimeStamp'] as String),
  );
} 