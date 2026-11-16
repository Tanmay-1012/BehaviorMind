import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(initSettings);
    _isInitialized = true;
  }

  Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'screen_time_channel',
      'Screen Time Notifications',
      channelDescription: 'Notifications about screen time usage',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(id, title, body, details);
  }

  Future<void> showScreenTimeWarning({
    required int screenTimeInMinutes,
    required int limitInMinutes,
  }) async {
    await showNotification(
      title: 'Screen Time Warning',
      body: 'You\'ve used your device for $screenTimeInMinutes minutes today. Your daily limit is $limitInMinutes minutes.',
    );
  }

  Future<void> showAppUsageWarning({
    required String appName,
    required int usageInMinutes,
    required int limitInMinutes,
  }) async {
    await showNotification(
      title: 'App Usage Warning',
      body: 'You\'ve used $appName for $usageInMinutes minutes today. Your daily limit is $limitInMinutes minutes.',
    );
  }
} 