import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:behaviormind/models/user_model.dart';
import 'package:behaviormind/models/health_data_model.dart';
import 'package:behaviormind/models/prediction_model.dart';
import 'package:behaviormind/models/activity_model.dart';

class StorageService {
  // User data storage keys
  static const String _userKey = 'user_data';
  
  // Health data storage keys
  static const String _healthDataKey = 'health_data';
  static const String _activityDataKey = 'activity_data';
  
  // Prediction data storage key
  static const String _predictionsKey = 'predictions';
  
  // Settings storage prefix
  static const String _settingsPrefix = 'setting_';
  
  // Save user data
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode(user.toMap());
    await prefs.setString(_userKey, userData);
  }
  
  // Get user data
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    
    if (userData != null) {
      return User.fromMap(json.decode(userData));
    }
    
    // Return demo user if no saved user exists
    return User.demo();
  }
  
  // Save health data
  Future<void> saveHealthData(List<HealthData> healthData) async {
    final prefs = await SharedPreferences.getInstance();
    final healthDataJson = healthData.map((data) => data.toMap()).toList();
    await prefs.setString(_healthDataKey, json.encode(healthDataJson));
  }
  
  // Get health data
  Future<List<HealthData>> getHealthData() async {
    final prefs = await SharedPreferences.getInstance();
    final healthDataJson = prefs.getString(_healthDataKey);
    
    if (healthDataJson != null) {
      final List<dynamic> decodedData = json.decode(healthDataJson);
      return decodedData.map((data) => HealthData.fromMap(data)).toList();
    }
    
    return [];
  }
  
  // Save activity data
  Future<void> saveActivityData(List<DailyActivity> activityData) async {
    final prefs = await SharedPreferences.getInstance();
    final activityDataJson = activityData.map((data) => data.toJson()).toList();
    await prefs.setString(_activityDataKey, json.encode(activityDataJson));
  }
  
  // Get activity data
  Future<List<DailyActivity>> getActivityData() async {
    final prefs = await SharedPreferences.getInstance();
    final activityDataJson = prefs.getString(_activityDataKey);
    
    if (activityDataJson != null) {
      final List<dynamic> decodedData = json.decode(activityDataJson);
      return decodedData.map((data) => DailyActivity.fromJson(data)).toList();
    }
    
    // Return a week of demo activity data
    final now = DateTime.now();
    final List<DailyActivity> demoActivities = [];
    
    for (int i = 0; i < 7; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      final dateStr = date.toIso8601String().split('T')[0];
      demoActivities.add(DailyActivity.demo(dateStr));
    }
    
    return demoActivities;
  }
  
  // Save predictions
  Future<void> savePredictions(List<Prediction> predictions) async {
    final prefs = await SharedPreferences.getInstance();
    final predictionsJson = predictions.map((pred) => pred.toMap()).toList();
    await prefs.setString(_predictionsKey, json.encode(predictionsJson));
  }
  
  // Get predictions
  Future<List<Prediction>> getPredictions() async {
    final prefs = await SharedPreferences.getInstance();
    final predictionsJson = prefs.getString(_predictionsKey);
    
    if (predictionsJson != null) {
      final List<dynamic> decodedData = json.decode(predictionsJson);
      return decodedData.map((data) => Prediction.fromMap(data)).toList();
    }
    
    // Return a demo prediction if none exists
    return [Prediction.demo()];
  }
  
  // Get a setting with a default value
  Future<T> getSetting<T>(String key, T defaultValue) async {
    final prefs = await SharedPreferences.getInstance();
    final fullKey = _settingsPrefix + key;
    
    if (!prefs.containsKey(fullKey)) {
      return defaultValue;
    }
    
    // Return the appropriate type based on the default value
    if (defaultValue is bool) {
      return (prefs.getBool(fullKey) as T?) ?? defaultValue;
    } else if (defaultValue is String) {
      return (prefs.getString(fullKey) as T?) ?? defaultValue;
    } else if (defaultValue is int) {
      return (prefs.getInt(fullKey) as T?) ?? defaultValue;
    } else if (defaultValue is double) {
      return (prefs.getDouble(fullKey) as T?) ?? defaultValue;
    }
    
    return defaultValue;
  }
  
  // Save a setting
  Future<void> saveSetting<T>(String key, T value) async {
    final prefs = await SharedPreferences.getInstance();
    final fullKey = _settingsPrefix + key;
    
    if (value is bool) {
      await prefs.setBool(fullKey, value);
    } else if (value is String) {
      await prefs.setString(fullKey, value);
    } else if (value is int) {
      await prefs.setInt(fullKey, value);
    } else if (value is double) {
      await prefs.setDouble(fullKey, value);
    }
  }
  
  // Clear all data (for logout or reset)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}