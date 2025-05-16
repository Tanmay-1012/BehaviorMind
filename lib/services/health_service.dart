import 'dart:math';
import 'package:health/health.dart';
import 'package:behaviormind/models/health_data_model.dart';
import 'package:behaviormind/utils/date_formatter.dart';

class HealthService {
  final HealthFactory _health = HealthFactory();
  bool _initialized = false;
  
  // Types of data to request from health services
  static const List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.DISTANCE_WALKING_RUNNING,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_REM,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.WORKOUT,
  ];
  
  // Initialize health services and request permissions
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // Request authorization for the health data types
      final permissionsGranted = await _health.requestAuthorization(_types);
      _initialized = permissionsGranted;
    } catch (e) {
      print('Error initializing health service: $e');
      // Fallback to demo mode if health services aren't available
      _initialized = true;
    }
  }
  
  // Get health data for a specific date
  Future<HealthData> getHealthData(DateTime date) async {
    final formattedDate = DateFormatter.formatIso(date);
    
    try {
      if (!_initialized) {
        await initialize();
      }
      
      if (_initialized) {
        // In a real app, this would fetch data from wearables/health services
        // For this prototype, we'll use demo data
        return _generateDemoHealthData(date);
      }
      
      // Fallback to empty health data
      return HealthData(
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
      );
    } catch (e) {
      print('Error fetching health data: $e');
      // Return demo data as fallback
      return _generateDemoHealthData(date);
    }
  }
  
  // Generate realistic demo health data for a date
  HealthData _generateDemoHealthData(DateTime date) {
    final random = Random();
    final formattedDate = DateFormatter.formatIso(date);
    
    // Base values with some variations
    final steps = 7000 + random.nextInt(4000);
    final distance = (steps / 1300).toDouble(); // roughly 1300 steps per km
    final activeMinutes = 30 + random.nextInt(60);
    final calories = 1600 + random.nextInt(800);
    final heartRate = 65 + random.nextInt(15);
    
    // Generate sleep data that varies by day of week
    final totalSleep = 6.0 + (random.nextDouble() * 2.5);
    final deepSleep = totalSleep * 0.2;
    final remSleep = totalSleep * 0.25;
    final lightSleep = totalSleep * 0.5;
    final awakeSleep = totalSleep * 0.05;
    
    final sleepData = SleepData(
      totalHours: totalSleep,
      deepSleepHours: deepSleep,
      lightSleepHours: lightSleep,
      remSleepHours: remSleep,
      awakeSleepHours: awakeSleep,
    );
    
    // Generate workouts based on day of week
    final workouts = <WorkoutData>[];
    
    // Weekday workouts
    if (date.weekday >= 1 && date.weekday <= 5) {
      // 60% chance of a workout on weekdays
      if (random.nextDouble() < 0.6) {
        // Morning or evening workout
        final isMorning = random.nextBool();
        final workoutType = _getRandomWorkoutType();
        final duration = 20 + random.nextInt(40);
        final caloriesBurned = (duration * 7 + random.nextInt(100));
        
        workouts.add(WorkoutData(
          type: workoutType,
          durationMinutes: duration,
          caloriesBurned: caloriesBurned,
          startTime: isMorning ? '06:30' : '18:00',
          endTime: isMorning ? '07:15' : '18:45',
        ));
      }
    } 
    // Weekend workouts
    else {
      // 70% chance of a workout on weekends
      if (random.nextDouble() < 0.7) {
        final workoutType = _getRandomWorkoutType();
        final duration = 30 + random.nextInt(60);
        final caloriesBurned = (duration * 8 + random.nextInt(150));
        
        workouts.add(WorkoutData(
          type: workoutType,
          durationMinutes: duration,
          caloriesBurned: caloriesBurned,
          startTime: '10:00',
          endTime: '11:15',
        ));
      }
    }
    
    return HealthData(
      date: formattedDate,
      steps: steps,
      distanceWalked: distance,
      activeMinutes: activeMinutes,
      caloriesBurned: calories,
      heartRate: heartRate,
      sleep: sleepData,
      workouts: workouts,
    );
  }
  
  // Helper to get a random workout type
  String _getRandomWorkoutType() {
    final types = [
      'Running', 
      'Walking', 
      'Cycling', 
      'Strength Training', 
      'Yoga', 
      'Swimming',
      'HIIT',
      'Pilates'
    ];
    
    return types[Random().nextInt(types.length)];
  }
}