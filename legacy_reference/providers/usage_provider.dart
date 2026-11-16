import 'package:flutter/foundation.dart';
import 'package:behaviormind/services/usage_service.dart';
// import 'package:app_usage/app_usage.dart'; // Removed old import
import 'package:behaviormind/services/app_category_service.dart';
// import 'package:app_settings/app_settings.dart'; // Recommended for opening specific settings pages

class UsageProvider with ChangeNotifier {
  final UsageService _usageService = UsageService();

  Duration? _totalScreenTime;
  Duration? get totalScreenTime => _totalScreenTime;

  List<ForegroundAppUsageInfo>? _appUsageInfos;
  List<ForegroundAppUsageInfo>? get appUsageInfos => _appUsageInfos;

  final Map<AppCategory, Duration> _categorizedAppUsage = {};
  Map<AppCategory, Duration> get categorizedAppUsage => _categorizedAppUsage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _requiresUsagePermission = false;
  bool get requiresUsagePermission => _requiresUsagePermission;

  // List of package name prefixes or exact names to exclude
  final List<String> _excludedPackages = [
    'com.android.systemui', // System UI
    'com.google.android.apps.nexuslauncher', // Pixel Launcher
    'com.android.launcher', // AOSP Launcher
    'com.android.settings', // Settings app

    // Samsung Specific
    'com.samsung.android.app.launcher', // Samsung One UI Home
    'com.sec.android.app.launcher', // Samsung One UI Home (alternative)
    'com.samsung.android.lool', // Samsung Device Care ("lool" in screenshot)
    'com.sec.android.emergencylauncher', // Samsung Emergency Launcher (from user feedback)
    'com.samsung.android.incallui', // Samsung In-Call UI
    'com.samsung.android.scloud', // Samsung Cloud
    'com.samsung.android.app.samsungapps', // Galaxy Apps / Store
    'com.sec.android.app.samsungapps', // Galaxy Apps / Store (alternative)
    'com.samsung.android.app.smartcapture', // Samsung Smart Capture
    // 'com.samsung.android.provider.', // Broad Samsung providers - Commented out as it might be too broad
    'com.sec.android.daemonapp', // Samsung Daemon App
    'com.monotype.android.font.samsung', // Samsung Fonts
    'com.samsung.android.themestore',
    'com.samsung.android.themecenter',
    'com.samsung.android.smartface',
    'com.samsung.android.globalactions',
    'com.samsung.android.dialer', // Samsung Dialer

    // General Android System
    'com.android.incallui', // Generic In-Call UI
    'com.android.permissioncontroller',
    'com.google.android.permissioncontroller',
    'com.android.packageinstaller',
    'com.google.android.packageinstaller',
    'com.android.providers.media.module', // Media Picker / Photo Picker
    'com.android.providers.downloads.ui',
    'com.android.providers.calendar',
    'com.android.providers.contacts',
    'com.android.providers.telephony',
    'com.android.server.', // Broad Android server components
    'com.android.shell',
    'com.android.wallpaperbackup',
    'com.android.wallpapercropper',
    'com.android.dreams.', // Daydreams / Screensavers
    'com.android.captiveportallogin',

    // Google Specific (besides launcher/permissioncontroller)
    'com.google.android.gms', // Google Play Services (often high background)
    'com.google.android.gsf', // Google Services Framework
    'com.google.android.partnersetup',
    'com.google.android.feedback', // Google Feedback Agent
    'com.google.android.apps.wellbeing', // Digital Wellbeing (ironically, don't count itself if it appears)
    // 'com.google.android.apps.photos', // Google Photos (if its background is high and not desired)

    // Common OEM Launchers & Services
    'com.mi.android.globallauncher', // Xiaomi MIUI Launcher
    'com.huawei.android.launcher', // Huawei EMUI Launcher
    'net.oneplus.launcher', // OnePlus Launcher
    // 'com.google.android.googlequicksearchbox', // Google App (often includes launcher components & voice services) - Temporarily commented out for diagnostics

    // Other potential candidates from screenshots if names are stable (exact package names are better)
    // 'imobile', // This is too generic - user needs to identify package name if it persists
    // 'android', // This is too generic
    // 'controller', // This is too generic
    'com.android.vending', // Google Play Store (already added, but ensure it's here)


    // Add more OEM-specific launchers or system apps as needed
    // e.g., 'com.motorola.launcher3', 'com.lge.launcher3', etc.
  ];

  Future<void> fetchScreenTime(DateTime startDate, DateTime endDate) async {
    _isLoading = true;
    _errorMessage = null;
    _requiresUsagePermission = false;
    _totalScreenTime = null;
    _appUsageInfos = null;
    _categorizedAppUsage.clear();
    notifyListeners();

    try {
      final List<ForegroundAppUsageInfo> usageInfosResult = 
          await _usageService.getForegroundAppUsage(startDate, endDate);

      // Filter out excluded packages from ForegroundAppUsageInfo
      final filteredUsageInfos = usageInfosResult.where((info) {
        // Ensure info.packageName is not null, though the service should provide 'Unknown' if null
        return !_excludedPackages.any((excluded) => info.packageName.startsWith(excluded));
      }).toList();

      _appUsageInfos = filteredUsageInfos;
      _totalScreenTime = _usageService.getTotalScreenTime(filteredUsageInfos);

      final queriedDuration = endDate.difference(startDate);
      if (_totalScreenTime != null && _totalScreenTime! > queriedDuration) {
        _totalScreenTime = queriedDuration;
        debugPrint('UsageProvider: Capped totalScreenTime to queried duration: ${_totalScreenTime.toString()}');
      }

      _categorizedAppUsage.clear();
      if (_appUsageInfos != null && _appUsageInfos!.isNotEmpty) {
        _calculateCategorizedUsage(_appUsageInfos!);
      }

    } catch (e) {
      debugPrint('UsageProvider: Error fetching screen time: ${e.toString()}');
      if (e.toString().toLowerCase().contains('permission is required')) {
        _errorMessage = 'Usage access permission is required. Please grant it in settings.';
        _requiresUsagePermission = true;
      } else {
        _errorMessage = 'Could not fetch screen time. Please try again later.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Opens the system settings page for "Usage Access".
  /// This typically requires a separate plugin like 'app_settings'.
  Future<void> openUsageAccessSettings() async {
    debugPrint('UsageProvider: openUsageAccessSettings called. The service layer handles opening settings.');
    if (_requiresUsagePermission) {
        _errorMessage = 'Please navigate to Settings > Apps > Special app access > Usage access, find BehaviorMind, and grant permission.';
    }
    notifyListeners();
  }

  // Helper method to calculate categorized usage
  void _calculateCategorizedUsage(List<ForegroundAppUsageInfo> usageInfos) {
    _categorizedAppUsage.clear();
    for (var appInfo in usageInfos) {
      final category = AppCategoryService.categorizeApp(
        packageName: appInfo.packageName,
        appName: appInfo.appName,
      );
      _categorizedAppUsage[category] =
          (_categorizedAppUsage[category] ?? Duration.zero) + appInfo.foregroundDuration;
    }
  }
} 