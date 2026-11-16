import 'package:health/health.dart' as health;
import 'package:behaviormind/utils/logger.dart';
import 'package:app_settings/app_settings.dart';

class HealthPermissionsService {
  static final HealthPermissionsService _instance = HealthPermissionsService._internal();
  factory HealthPermissionsService() => _instance;
  HealthPermissionsService._internal();

  final health.Health _health = health.Health();

  // Define the types of health data we want to access
  final List<health.HealthDataType> _types = [
    health.HealthDataType.STEPS,
    health.HealthDataType.ACTIVE_ENERGY_BURNED,
    health.HealthDataType.HEART_RATE,
    health.HealthDataType.SLEEP_ASLEEP,
    health.HealthDataType.SLEEP_AWAKE,
    health.HealthDataType.SLEEP_IN_BED,
    health.HealthDataType.EXERCISE_TIME,
    health.HealthDataType.WORKOUT,
  ];

  Future<bool> requestPermissions() async {
    try {
      // Request authorization for all types
      final authorized = await _health.requestAuthorization(_types);
      
      if (!authorized) {
        AppLogger.warning('Health permissions not granted');
        await AppSettings.openAppSettings();
        return false;
      }

      // Verify each permission individually
      for (final type in _types) {
        final hasPermission = await _health.hasPermissions([type]);
        if (hasPermission == null || !hasPermission) {
          AppLogger.warning('Permission not granted for ${type.toString()}');
          await AppSettings.openAppSettings();
          return false;
        }
      }

      AppLogger.info('All health permissions granted');
      return true;
    } catch (e) {
      AppLogger.error('Error requesting health permissions: $e');
      return false;
    }
  }

  Future<bool> checkPermissions() async {
    try {
      // Check if we have authorization for all types
      final authorized = await _health.hasPermissions(_types);
      
      if (authorized == null || !authorized) {
        AppLogger.warning('Health permissions not granted');
        return false;
      }

      AppLogger.info('All health permissions are granted');
      return true;
    } catch (e) {
      AppLogger.error('Error checking health permissions: $e');
      return false;
    }
  }
} 