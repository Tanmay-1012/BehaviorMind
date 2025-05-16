import 'package:flutter/foundation.dart';
import 'package:behaviormind/services/storage_service.dart';

class SettingsProvider with ChangeNotifier {
  // Settings variables
  bool _isDarkMode = true;
  String _language = 'English';
  bool _autoDataSync = true;
  bool _googleFitConnected = false;
  bool _samsungHealthConnected = false;
  String _locationAccess = 'Allow';
  String _browserNotifications = 'Allow';
  String _cameraAccess = 'Allow';
  
  // Notification settings
  bool _inAppAlerts = false;
  bool _dailyInsights = true;
  bool _lowActivityAlerts = true;
  bool _sleepGoalReminders = true;
  bool _predictionUpdates = true;
  bool _weeklyProgress = true;
  
  final StorageService _storageService = StorageService();
  
  // Constructor
  SettingsProvider() {
    _loadSettings();
  }
  
  // Getters for all settings
  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  bool get autoDataSync => _autoDataSync;
  bool get googleFitConnected => _googleFitConnected;
  bool get samsungHealthConnected => _samsungHealthConnected;
  String get locationAccess => _locationAccess;
  String get browserNotifications => _browserNotifications;
  String get cameraAccess => _cameraAccess;
  
  // Notification getters
  bool get inAppAlerts => _inAppAlerts;
  bool get dailyInsights => _dailyInsights;
  bool get lowActivityAlerts => _lowActivityAlerts;
  bool get sleepGoalReminders => _sleepGoalReminders;
  bool get predictionUpdates => _predictionUpdates;
  bool get weeklyProgress => _weeklyProgress;
  
  // Load all settings from storage
  Future<void> _loadSettings() async {
    _isDarkMode = await _storageService.getSetting('isDarkMode', true);
    _language = await _storageService.getSetting('language', 'English');
    _autoDataSync = await _storageService.getSetting('autoDataSync', true);
    _googleFitConnected = await _storageService.getSetting('googleFitConnected', false);
    _samsungHealthConnected = await _storageService.getSetting('samsungHealthConnected', false);
    _locationAccess = await _storageService.getSetting('locationAccess', 'Allow');
    _browserNotifications = await _storageService.getSetting('browserNotifications', 'Allow');
    _cameraAccess = await _storageService.getSetting('cameraAccess', 'Allow');
    
    _inAppAlerts = await _storageService.getSetting('inAppAlerts', false);
    _dailyInsights = await _storageService.getSetting('dailyInsights', true);
    _lowActivityAlerts = await _storageService.getSetting('lowActivityAlerts', true);
    _sleepGoalReminders = await _storageService.getSetting('sleepGoalReminders', true);
    _predictionUpdates = await _storageService.getSetting('predictionUpdates', true);
    _weeklyProgress = await _storageService.getSetting('weeklyProgress', true);
    
    notifyListeners();
  }
  
  // Set dark mode
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _storageService.saveSetting('isDarkMode', value);
    notifyListeners();
  }
  
  // Set language
  Future<void> setLanguage(String value) async {
    _language = value;
    await _storageService.saveSetting('language', value);
    notifyListeners();
  }
  
  // Set auto data sync
  Future<void> setAutoDataSync(bool value) async {
    _autoDataSync = value;
    await _storageService.saveSetting('autoDataSync', value);
    notifyListeners();
  }
  
  // Set Google Fit connection
  Future<void> setGoogleFitConnected(bool value) async {
    _googleFitConnected = value;
    await _storageService.saveSetting('googleFitConnected', value);
    notifyListeners();
  }
  
  // Set Samsung Health connection
  Future<void> setSamsungHealthConnected(bool value) async {
    _samsungHealthConnected = value;
    await _storageService.saveSetting('samsungHealthConnected', value);
    notifyListeners();
  }
  
  // Set location access
  Future<void> setLocationAccess(String value) async {
    _locationAccess = value;
    await _storageService.saveSetting('locationAccess', value);
    notifyListeners();
  }
  
  // Set browser notifications
  Future<void> setBrowserNotifications(String value) async {
    _browserNotifications = value;
    await _storageService.saveSetting('browserNotifications', value);
    notifyListeners();
  }
  
  // Set camera access
  Future<void> setCameraAccess(String value) async {
    _cameraAccess = value;
    await _storageService.saveSetting('cameraAccess', value);
    notifyListeners();
  }
  
  // Set notification settings
  Future<void> setInAppAlerts(bool value) async {
    _inAppAlerts = value;
    await _storageService.saveSetting('inAppAlerts', value);
    notifyListeners();
  }
  
  Future<void> setDailyInsights(bool value) async {
    _dailyInsights = value;
    await _storageService.saveSetting('dailyInsights', value);
    notifyListeners();
  }
  
  Future<void> setLowActivityAlerts(bool value) async {
    _lowActivityAlerts = value;
    await _storageService.saveSetting('lowActivityAlerts', value);
    notifyListeners();
  }
  
  Future<void> setSleepGoalReminders(bool value) async {
    _sleepGoalReminders = value;
    await _storageService.saveSetting('sleepGoalReminders', value);
    notifyListeners();
  }
  
  Future<void> setPredictionUpdates(bool value) async {
    _predictionUpdates = value;
    await _storageService.saveSetting('predictionUpdates', value);
    notifyListeners();
  }
  
  Future<void> setWeeklyProgress(bool value) async {
    _weeklyProgress = value;
    await _storageService.saveSetting('weeklyProgress', value);
    notifyListeners();
  }
  
  // Reset all settings to defaults
  Future<void> resetToDefaults() async {
    _isDarkMode = true;
    _language = 'English';
    _autoDataSync = true;
    _googleFitConnected = false;
    _samsungHealthConnected = false;
    _locationAccess = 'Allow';
    _browserNotifications = 'Allow';
    _cameraAccess = 'Allow';
    
    _inAppAlerts = false;
    _dailyInsights = true;
    _lowActivityAlerts = true;
    _sleepGoalReminders = true;
    _predictionUpdates = true;
    _weeklyProgress = true;
    
    await _saveAllSettings();
    notifyListeners();
  }
  
  // Save all settings at once
  Future<void> _saveAllSettings() async {
    await _storageService.saveSetting('isDarkMode', _isDarkMode);
    await _storageService.saveSetting('language', _language);
    await _storageService.saveSetting('autoDataSync', _autoDataSync);
    await _storageService.saveSetting('googleFitConnected', _googleFitConnected);
    await _storageService.saveSetting('samsungHealthConnected', _samsungHealthConnected);
    await _storageService.saveSetting('locationAccess', _locationAccess);
    await _storageService.saveSetting('browserNotifications', _browserNotifications);
    await _storageService.saveSetting('cameraAccess', _cameraAccess);
    
    await _storageService.saveSetting('inAppAlerts', _inAppAlerts);
    await _storageService.saveSetting('dailyInsights', _dailyInsights);
    await _storageService.saveSetting('lowActivityAlerts', _lowActivityAlerts);
    await _storageService.saveSetting('sleepGoalReminders', _sleepGoalReminders);
    await _storageService.saveSetting('predictionUpdates', _predictionUpdates);
    await _storageService.saveSetting('weeklyProgress', _weeklyProgress);
  }
}
