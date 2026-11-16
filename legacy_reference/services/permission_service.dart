import 'package:permission_handler/permission_handler.dart';
import 'package:health/health.dart' show Health, HealthDataType;
import 'package:behaviormind/utils/logger.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  final Health _health = Health();

  // Define the types of health data we want to access
  final List<HealthDataType> _healthTypes = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.EXERCISE_TIME,
    HealthDataType.WORKOUT,
  ];

  Future<bool> requestAllPermissions() async {
    try {
      // Request basic permissions
      final basicPermissions = await _requestBasicPermissions();
      if (!basicPermissions) {
        AppLogger.warning('Basic permissions not granted');
        return false;
      }

      // Request health permissions
      final healthPermissions = await _requestHealthPermissions();
      if (!healthPermissions) {
        AppLogger.warning('Health permissions not granted');
        return false;
      }

      // Request usage stats permission
      final usageStatsPermission = await _requestUsageStatsPermission();
      if (!usageStatsPermission) {
        AppLogger.warning('Usage stats permission not granted');
        return false;
      }

      AppLogger.info('All permissions granted');
      return true;
    } catch (e) {
      AppLogger.error('Error requesting permissions: $e');
      return false;
    }
  }

  Future<bool> _requestBasicPermissions() async {
    try {
      // Request activity recognition permission
      final activityStatus = await Permission.activityRecognition.request();
      if (!activityStatus.isGranted) {
        AppLogger.warning('Activity recognition permission not granted');
        return false;
      }

      // Request location permission
      final locationStatus = await Permission.location.request();
      if (!locationStatus.isGranted) {
        AppLogger.warning('Location permission not granted');
        return false;
      }

      // Request storage permissions
      final isStorageDenied = await Permission.storage.isDenied;
      if (isStorageDenied) {
        final storageStatus = await Permission.storage.request();
        final isGranted = storageStatus.isGranted;
        if (!isGranted) {
          AppLogger.warning('Storage permission not granted');
          return false;
        }
      }

      return true;
    } catch (e) {
      AppLogger.error('Error requesting basic permissions: $e');
      return false;
    }
  }

  Future<bool> _requestHealthPermissions() async {
    try {
      // Request authorization for all health types
      final authorized = await _health.requestAuthorization(_healthTypes);
      
      if (!authorized) {
        AppLogger.warning('Health permissions not granted');
        return false;
      }

      // Verify each permission individually
      for (final type in _healthTypes) {
        final hasPermission = await _health.hasPermissions([type]);
        if (hasPermission == null || !hasPermission) {
          AppLogger.warning('Permission not granted for ${type.toString()}');
          return false;
        }
      }

      return true;
    } catch (e) {
      AppLogger.error('Error requesting health permissions: $e');
      return false;
    }
  }

  Future<bool> _requestUsageStatsPermission() async {
    try {
      // Open usage stats settings
      await openAppSettings();
      return true;
    } catch (e) {
      AppLogger.error('Error requesting usage stats permission: $e');
      return false;
    }
  }

  Future<bool> checkAllPermissions() async {
    try {
      // Check basic permissions
      final hasActivityPermission = await Permission.activityRecognition.isGranted;
      final hasLocationPermission = await Permission.location.isGranted;
      final hasStoragePermission = await Permission.storage.isGranted;

      if (hasActivityPermission != true || hasLocationPermission != true || hasStoragePermission != true) {
        AppLogger.warning('Basic permissions not granted');
        return false;
      }

      // Check health permissions
      final hasHealthPermissions = await _health.hasPermissions(_healthTypes);
      if (hasHealthPermissions != true) {
        AppLogger.warning('Health permissions not granted');
        return false;
      }

      return true;
    } catch (e) {
      AppLogger.error('Error checking permissions: $e');
      return false;
    }
  }

  Future<void> openAppSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      AppLogger.error('Error opening app settings: $e');
    }
  }
} 