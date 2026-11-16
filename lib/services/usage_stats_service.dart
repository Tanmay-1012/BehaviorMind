import 'dart:developer' as developer;
import 'package:usage_stats/usage_stats.dart';

class UsageStatsService {
  Future<bool> checkAndRequestUsagePermission() async {
    bool? isPermissionGranted = await UsageStats.checkUsagePermission();
    if (isPermissionGranted == null || !isPermissionGranted) {
      await UsageStats.grantUsagePermission();
      // Check again after attempting to grant
      isPermissionGranted = await UsageStats.checkUsagePermission();
    }
    return isPermissionGranted ?? false;
  }

  Future<List<UsageInfo>> getUsageStats() async {
    try {
      // It's good practice to ensure permission is granted before querying
      bool hasPermission = await checkAndRequestUsagePermission();
      if (!hasPermission) {
        developer.log('Usage permission not granted. Cannot fetch stats.');
        return []; // Return empty or throw an error, based on how you want to handle it
      }

      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(const Duration(days: 1));

      List<UsageInfo> usageStats = await UsageStats.queryUsageStats(startDate, endDate);
      
      return usageStats.where((usageInfo) {
        bool isSystemApp = usageInfo.packageName?.contains('android') == true ||
                           usageInfo.packageName?.contains('system') == true ||
                           usageInfo.packageName?.contains('com.qualcomm') == true ||
                           usageInfo.packageName?.contains('com.google.android') == true;
                           
        double timeInForegroundMs = double.tryParse(usageInfo.totalTimeInForeground ?? '') ?? 0.0;
        bool hasForegroundTime = timeInForegroundMs > 0;

        return !isSystemApp && hasForegroundTime;
      }).toList();
    } catch (e, stackTrace) {
      developer.log('Error fetching usage stats: $e', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  Map<String, List<UsageInfo>> categorizeApps(List<UsageInfo> usageStats) {
    Map<String, List<UsageInfo>> categorizedApps = {
      'Finance': [],
      'Sports': [],
      'News': [],
      'Productivity': [],
      'Social': [],
      'Games': [],
      'Entertainment': [],
      'Utilities': [],
      'Education': [],
      'Lifestyle': [],
      'Other': [],
    };

    for (var usageInfo in usageStats) {
      String? packageName = usageInfo.packageName?.toLowerCase();
      if (packageName == null) continue;

      if (packageName.contains('finance') || packageName.contains('bank') || packageName.contains('paypal') || packageName.contains('paytm')) {
        categorizedApps['Finance']!.add(usageInfo);
      } else if (packageName.contains('sport') || packageName.contains('espn') || packageName.contains('cricket')) {
        categorizedApps['Sports']!.add(usageInfo);
      } else if (packageName.contains('news') || packageName.contains('cnn') || packageName.contains('bbc')) {
        categorizedApps['News']!.add(usageInfo);
      } else if (packageName.contains('productivity') || packageName.contains('office') || packageName.contains('docs') || packageName.contains('drive') || packageName.contains('slack') || packageName.contains('zoom')) {
        categorizedApps['Productivity']!.add(usageInfo);
      } else if (packageName.contains('social') || packageName.contains('facebook') || packageName.contains('instagram') || packageName.contains('twitter') || packageName.contains('whatsapp') || packageName.contains('snapchat')) {
        categorizedApps['Social']!.add(usageInfo);
      } else if (packageName.contains('game') || packageName.contains('gaming') || packageName.contains('pubg') || packageName.contains('fortnite')) {
        categorizedApps['Games']!.add(usageInfo);
      } else if (packageName.contains('youtube') || packageName.contains('netflix') || packageName.contains('spotify') || packageName.contains('music') || packageName.contains('video')) {
        categorizedApps['Entertainment']!.add(usageInfo);
      } else if (packageName.contains('tool') || packageName.contains('util') || packageName.contains('calculator') || packageName.contains('file')) {
        categorizedApps['Utilities']!.add(usageInfo);
      } else if (packageName.contains('edu') || packageName.contains('learn') || packageName.contains('coursera') || packageName.contains('udemy')) {
        categorizedApps['Education']!.add(usageInfo);
      } else if (packageName.contains('life') || packageName.contains('health') || packageName.contains('fitness') || packageName.contains('travel')) {
        categorizedApps['Lifestyle']!.add(usageInfo);
      } else {
        categorizedApps['Other']!.add(usageInfo);
      }
    }
    return categorizedApps;
  }
} 