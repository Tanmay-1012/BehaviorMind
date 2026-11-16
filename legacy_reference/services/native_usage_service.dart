import 'package:flutter/services.dart';
import 'package:app_settings/app_settings.dart';
import 'package:behaviormind/utils/logger.dart';

class NativeUsageService {
  static const platform = MethodChannel('com.behaviormind/usage');

  static Future<Map<String, dynamic>> getScreenOnTime(DateTime startTime, DateTime endTime) async {
    try {
      final Map<dynamic, dynamic> result = await platform.invokeMethod('getScreenOnTime', {
        'startTime': startTime.millisecondsSinceEpoch,
        'endTime': endTime.millisecondsSinceEpoch,
      });
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      AppLogger.error("Failed to get screen-on time: '${e.message}'.");
      return {
        'totalScreenOnTime': 0,
        'appUsage': <String, int>{},
      };
    }
  }

  static Future<Map<String, dynamic>> getAppUsage(DateTime startTime, DateTime endTime) async {
    try {
      final Map<dynamic, dynamic> result = await platform.invokeMethod('getAppUsage', {
        'startTime': startTime.millisecondsSinceEpoch,
        'endTime': endTime.millisecondsSinceEpoch,
      });
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      AppLogger.error("Failed to get app usage: '${e.message}'.");
      return {
        'appUsage': <String, int>{},
      };
    }
  }

  static Future<void> openUsageSettings() async {
    await AppSettings.openAppSettings();
  }
} 