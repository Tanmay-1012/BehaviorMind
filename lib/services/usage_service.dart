import 'package:app_usage/app_usage.dart';
import 'package:flutter/foundation.dart';

class UsageService {
  /// Fetches app usage statistics for the given date range.
  ///
  /// Throws [AppUsageException] if permission is not granted or another error occurs.
  /// In case of an [AppUsageException], the user might need to be guided to
  /// system settings to grant "Usage access" permission for this app.
  Future<List<AppUsageInfo>> getAppUsage(DateTime startDate, DateTime endDate) async {
    // try {
    //   List<AppUsageInfo> infoList = await AppUsage().getAppUsage(startDate, endDate);
    //   // You can sort the list if needed, e.g., by usage time
    //   // infoList.sort((a, b) => b.usage.compareTo(a.usage));
    //   return infoList;
    // } catch (exception) {
    //   // Since the linter has trouble with 'AppUsageException' type,
    //   // we catch broadly. The primary expected exception from AppUsage()
    //   // on permission issues would be an AppUsageException.
    //   debugPrint('Exception during getAppUsage: \\${exception.toString()}');
    //   // Consider checking exception.runtimeType.toString() if you need to differentiate
    //   // without a direct type check, or inspect the message.
    //   // For now, assume any exception from here might indicate a permission issue or plugin error.
    //   rethrow; // Rethrow to be handled by the UI, which should guide the user about permissions.
    // }
    debugPrint('UsageService.getAppUsage temporarily disabled for testing health plugin.');
    return []; // Temporarily return empty list to bypass app_usage plugin
  }

  /// Calculates total screen time by summing up the usage duration of all apps in the list.
  /// Note: This represents the sum of foreground time for tracked apps, which is a good
  /// proxy for "screen on time" related to app usage.
  Duration getTotalScreenTime(List<AppUsageInfo> usageInfos) {
    Duration total = Duration.zero;
    for (var info in usageInfos) {
      total += info.usage;
    }
    return total;
  }

  /// A helper to format Duration into a more readable string like "1h 23m"
  String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return "\${duration.inHours}h \${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}m";
    } else if (duration.inMinutes > 0) {
      return "\${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}m \${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}s";
    } else {
      return "\${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}s";
    }
  }
} 