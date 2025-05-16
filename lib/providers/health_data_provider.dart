import 'package:flutter/foundation.dart';
import 'package:behaviormind/models/health_data_model.dart';
import 'package:behaviormind/models/activity_model.dart';
import 'package:behaviormind/services/health_service.dart';
import 'package:behaviormind/services/storage_service.dart';

class HealthDataProvider with ChangeNotifier {
  List<HealthData> _healthData = [];
  List<DailyActivity> _activityData = [];
  final HealthService _healthService = HealthService();
  final StorageService _storageService = StorageService();
  bool _isInitialized = false;
  
  List<HealthData> get healthData => List.unmodifiable(_healthData);
  List<DailyActivity> get activityData => List.unmodifiable(_activityData);
  
  HealthData? get latestHealthData => 
      _healthData.isNotEmpty ? _healthData.last : null;
  
  // Initialize health services
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _healthService.initialize();
      await loadHealthData();
      await loadActivityData();
      _isInitialized = true;
    } catch (e) {
      print('Error initializing health data provider: $e');
    }
  }
  
  // Load health data from storage
  Future<void> loadHealthData() async {
    try {
      final storedData = await _storageService.getHealthData();
      
      if (storedData.isNotEmpty) {
        _healthData = storedData;
      } else {
        // Generate initial health data for past week if none exists
        await _generateInitialHealthData();
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading health data: $e');
    }
  }
  
  // Load activity data from storage
  Future<void> loadActivityData() async {
    try {
      final storedData = await _storageService.getActivityData();
      
      if (storedData.isNotEmpty) {
        _activityData = storedData;
      } else {
        // Generate initial activity data if none exists
        await _generateInitialActivityData();
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading activity data: $e');
    }
  }
  
  // Generate initial health data for demonstration
  Future<void> _generateInitialHealthData() async {
    final now = DateTime.now();
    List<HealthData> generatedData = [];
    
    // Generate data for past 7 days
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final healthData = await _healthService.getHealthData(date);
      generatedData.add(healthData);
    }
    
    _healthData = generatedData;
    await _storageService.saveHealthData(_healthData);
  }
  
  // Generate initial activity data for demonstration
  Future<void> _generateInitialActivityData() async {
    final now = DateTime.now();
    List<DailyActivity> generatedData = [];
    
    // Map mood types to days for consistency
    final moodMap = {
      0: MoodType.positive,
      1: MoodType.neutral,
      2: MoodType.negative,
      3: MoodType.mixed,
      4: MoodType.negative,
      5: MoodType.neutral,
      6: MoodType.positive,
    };
    
    // Generate data for past 7 days
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // Find corresponding health data
      final healthData = _healthData.firstWhere(
        (data) => data.date == formattedDate,
        orElse: () => HealthData(
          date: formattedDate,
          steps: 0,
          distanceWalked: 0,
          activeMinutes: 0,
          caloriesBurned: 0,
          heartRate: 0,
          sleep: SleepData(
            totalHours: 0,
            deepSleepHours: 0,
            lightSleepHours: 0,
            remSleepHours: 0,
            awakeSleepHours: 0,
          ),
          workouts: [],
        ),
      );
      
      // Create suggestions based on day of week
      List<String> suggestions = [];
      Map<String, bool> suggestionsFollowed = {};
      
      switch (date.weekday) {
        case 1: // Monday
          suggestions.add('Take a 10-minute walk after lunch.');
          suggestionsFollowed['Take a 10-minute walk after lunch.'] = false;
          break;
        case 2: // Tuesday
          suggestions.add('Try a 5-minute mindfulness exercise.');
          suggestionsFollowed['Try a 5-minute mindfulness exercise.'] = true;
          break;
        case 3: // Wednesday
          suggestions.add('Limit screen time 1 hour before bed.');
          suggestionsFollowed['Limit screen time 1 hour before bed.'] = false;
          break;
        case 4: // Thursday
          suggestions.add('Prepare a healthy snack for the afternoon.');
          suggestionsFollowed['Prepare a healthy snack for the afternoon.'] = false;
          break;
        case 5: // Friday
          suggestions.add('Take short breaks during work periods.');
          suggestionsFollowed['Take short breaks during work periods.'] = true;
          break;
        case 6: // Saturday
          suggestions.add('Try to get outside for some natural light.');
          suggestionsFollowed['Try to get outside for some natural light.'] = true;
          break;
        case 7: // Sunday
          suggestions.add('Prepare for the week ahead with a to-do list.');
          suggestionsFollowed['Prepare for the week ahead with a to-do list.'] = false;
          break;
      }
      
      // Create prediction based on day of week
      Map<String, dynamic> prediction = {};
      
      if (date.weekday == 1) {
        prediction = {'type': 'focus', 'message': 'Predicted high focus for morning tasks.'};
      } else if (date.weekday == 2) {
        prediction = {'type': 'slump', 'message': 'Potential for afternoon slump.'};
      } else if (date.weekday == 3) {
        prediction = {'type': 'activity', 'message': 'Likely to exceed step goal.'};
      } else if (date.weekday == 4) {
        prediction = {'type': 'relaxation', 'message': 'Evening relaxation period identified.'};
      } else if (date.weekday == 5) {
        prediction = {'type': 'screen', 'message': 'Risk of high screen time before bed.'};
      } else {
        prediction = {'type': 'general', 'message': 'Average activity expected today.'};
      }
      
      // Create daily activity entry
      final dailyActivity = DailyActivity(
        date: formattedDate,
        steps: healthData.steps,
        screenTimeHours: 1.5 + (date.day % 5),
        mood: moodMap[i] ?? MoodType.neutral,
        prediction: prediction,
        suggestions: suggestions,
        suggestionsFollowed: suggestionsFollowed,
      );
      
      generatedData.add(dailyActivity);
    }
    
    _activityData = generatedData;
    await _storageService.saveActivityData(_activityData);
  }
  
  // Sync with health services to get latest data
  Future<void> syncHealthData() async {
    try {
      await _healthService.initialize();
      
      final now = DateTime.now();
      final todayData = await _healthService.getHealthData(now);
      
      // Check if today's data already exists
      final todayExists = _healthData.any((data) => data.date == todayData.date);
      
      if (todayExists) {
        // Update today's data
        _healthData = _healthData.map((data) => 
          data.date == todayData.date ? todayData : data
        ).toList();
      } else {
        // Add today's data
        _healthData.add(todayData);
      }
      
      await _storageService.saveHealthData(_healthData);
      notifyListeners();
    } catch (e) {
      print('Error syncing health data: $e');
    }
  }
  
  // Update activity data
  Future<void> updateActivityData(DailyActivity activity) async {
    final index = _activityData.indexWhere((a) => a.date == activity.date);
    
    if (index >= 0) {
      _activityData[index] = activity;
    } else {
      _activityData.add(activity);
    }
    
    await _storageService.saveActivityData(_activityData);
    notifyListeners();
  }
  
  // Update suggestion follow status
  Future<void> updateSuggestionStatus(String date, String suggestion, bool followed) async {
    final index = _activityData.indexWhere((a) => a.date == date);
    
    if (index >= 0) {
      final activity = _activityData[index];
      final updatedFollowed = Map<String, bool>.from(activity.suggestionsFollowed);
      updatedFollowed[suggestion] = followed;
      
      final updatedActivity = DailyActivity(
        date: activity.date,
        steps: activity.steps,
        screenTimeHours: activity.screenTimeHours,
        mood: activity.mood,
        prediction: activity.prediction,
        suggestions: activity.suggestions,
        suggestionsFollowed: updatedFollowed,
      );
      
      _activityData[index] = updatedActivity;
      await _storageService.saveActivityData(_activityData);
      notifyListeners();
    }
  }
  
  // Get health data for a specific date range
  List<HealthData> getHealthDataForRange(DateTime startDate, DateTime endDate) {
    return _healthData.where((data) {
      final dataDate = DateTime.parse(data.date);
      return (dataDate.isAfter(startDate) || dataDate.isAtSameMomentAs(startDate)) && 
             (dataDate.isBefore(endDate) || dataDate.isAtSameMomentAs(endDate));
    }).toList();
  }
  
  // Get activity data for a specific date range
  List<DailyActivity> getActivityDataForRange(DateTime startDate, DateTime endDate) {
    return _activityData.where((data) {
      final dataDate = DateTime.parse(data.date);
      return (dataDate.isAfter(startDate) || dataDate.isAtSameMomentAs(startDate)) && 
             (dataDate.isBefore(endDate) || dataDate.isAtSameMomentAs(endDate));
    }).toList();
  }
  
  // Get historical activity data for display
  List<DailyActivity> getActivityHistory() {
    // Sort activities by date, newest first
    List<DailyActivity> sortedActivities = List<DailyActivity>.from(_activityData);
    sortedActivities.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
    
    // If we have less than 15 days of data, generate more
    if (sortedActivities.length < 15) {
      _generateMoreHistoricalData(15 - sortedActivities.length);
      // Resort after generating
      sortedActivities = List<DailyActivity>.from(_activityData);
      sortedActivities.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
    }
    
    return sortedActivities;
  }
  
  // Generate additional historical data
  Future<void> _generateMoreHistoricalData(int daysNeeded) async {
    final now = DateTime.now();
    final List<DailyActivity> newData = [];
    
    // Find the oldest date we have
    DateTime oldestDate = now;
    if (_activityData.isNotEmpty) {
      final dates = _activityData.map((a) => DateTime.parse(a.date)).toList();
      dates.sort();
      oldestDate = dates.first;
    }
    
    // Generate data for days before the oldest date
    for (int i = 1; i <= daysNeeded; i++) {
      final date = oldestDate.subtract(Duration(days: i));
      final formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // Check if we already have data for this date
      final existingIndex = _activityData.indexWhere((a) => a.date == formattedDate);
      if (existingIndex >= 0) continue;
      
      // Create demo activity for this date
      final demoActivity = DailyActivity.demo(formattedDate);
      newData.add(demoActivity);
    }
    
    // Add new data to existing data
    _activityData.addAll(newData);
    await _storageService.saveActivityData(_activityData);
    notifyListeners();
  }
  
  // Variables for tracking the current viewing date
  DateTime _currentViewDate = DateTime.now();
  
  DateTime get currentViewDate => _currentViewDate;
  
  // Navigate to previous day
  void navigateToPreviousDay() {
    _currentViewDate = _currentViewDate.subtract(Duration(days: 1));
    notifyListeners();
  }
  
  // Navigate to next day
  void navigateToNextDay() {
    final nextDate = _currentViewDate.add(Duration(days: 1));
    // Don't navigate beyond today
    if (!nextDate.isAfter(DateTime.now())) {
      _currentViewDate = nextDate;
      notifyListeners();
    }
  }
}
