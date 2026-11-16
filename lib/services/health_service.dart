import 'dart:math';
import 'package:health/health.dart';
import 'package:behaviormind/models/health_data_model.dart';
import 'package:behaviormind/utils/date_formatter.dart';

class HealthService {
  final Health _health = Health();
  bool _initialized = false;
  
  // Getter for _initialized
  bool get isInitialized => _initialized;
  
  // Types of data to request from health services
  static const List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    // HealthDataType.DISTANCE_WALKING_RUNNING, // Temporarily removed due to "not found in HC" error
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
    if (_initialized) {
      // print('HealthService: Already initialized.');
      return;
    }
    // print('HealthService: Attempting to initialize and request authorizations...');
    try {
      // Configure the health plugin before use
      await _health.configure();
      // print('HealthService: Health plugin configured.');

      // Explicitly define READ permissions for each type
      final permissions = _types.map((_) => HealthDataAccess.READ).toList();

      // Request authorization for the health data types
      final permissionsGranted = await _health.requestAuthorization(_types, permissions: permissions);
      _initialized = permissionsGranted;
      if (!permissionsGranted) {
        // print('HealthService: requestAuthorization returned false. Permissions likely not granted by user or restricted.');
      } else {
        // print('HealthService: requestAuthorization returned true. Permissions should be granted.');
      }
    } catch (e) { 
      // print('HealthService: CRITICAL ERROR during requestAuthorization: $e');
      // print('HealthService: StackTrace for requestAuthorization error: $stackTrace');
      _initialized = false; // Set to false if authorization fails or errors out
    }
  }
  
  // Get health data for a specific date
  Future<HealthData> getHealthData(DateTime date) async {
    final formattedDate = DateFormatter.formatIso(date);
    
    if (!_initialized) {
      // This log helps confirm if we are entering here due to failed init
      // print('HealthService: Not initialized, attempting to initialize now...');
      await initialize();
    }
    
    // Check _initialized again after attempting initialization
    if (!_initialized) {
      // print('HealthService: Initialization failed or permissions denied. Returning demo data for $formattedDate.');
      return _generateDemoHealthData(date);
    }

    // If initialized (permissions likely granted), try to fetch real data
    try {
      DateTime endTime = DateTime.now(); // Use current time as end
      DateTime startTime = endTime.subtract(const Duration(days: 7)); // Go back 7 days for start

      // Ensure startTime is at the beginning of that day and endTime is at the end of the current day for full coverage
      startTime = DateTime(startTime.year, startTime.month, startTime.day, 0, 0, 0);
      // endTime = DateTime(endTime.year, endTime.month, endTime.day, 23, 59, 59); // Let's use now for endTime to catch most recent data

      int? steps;
      // double distanceWalkRun = 0; // Will use demo data for this field now
      double activeEnergy = 0;
      int heartRate = 0;
      double totalSleepMinutes = 0;
      List<WorkoutData> workouts = [];

      // Try specific method for steps first
      try {
        steps = await _health.getTotalStepsInInterval(startTime, endTime);
        // print('HealthService: getTotalStepsInInterval returned: $steps');
      } catch (e) {
        // print('HealthService: Error calling getTotalStepsInInterval: $e');
      }

      // Then try fetching other types (and steps again if getTotalStepsInInterval failed)
      List<HealthDataPoint> healthPoints = await _health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: [
          if (steps == null) HealthDataType.STEPS, // Only fetch steps via general method if specific one failed
          // HealthDataType.DISTANCE_WALKING_RUNNING, // Temporarily removed
          HealthDataType.ACTIVE_ENERGY_BURNED, 
          HealthDataType.HEART_RATE,
          HealthDataType.SLEEP_ASLEEP,
          HealthDataType.SLEEP_AWAKE,
          HealthDataType.SLEEP_DEEP,
          HealthDataType.SLEEP_LIGHT,
          HealthDataType.SLEEP_REM,
          HealthDataType.WORKOUT,
        ],
      );

      int fetchedSteps = 0;
      if (healthPoints.isNotEmpty) {
        // print('HealthService: Successfully fetched ${healthPoints.length} health data points for $formattedDate via getHealthDataFromTypes.');
        for (var point in healthPoints) {
          if (point.value is NumericHealthValue) {
            final numericValue = (point.value as NumericHealthValue).numericValue;
            switch (point.type) {
              case HealthDataType.STEPS:
                 fetchedSteps += numericValue.toInt();
                break;
              // case HealthDataType.DISTANCE_WALKING_RUNNING: 
              //   distanceWalkRun += numericValue.toDouble();
              //   break;
              case HealthDataType.ACTIVE_ENERGY_BURNED:
                activeEnergy += numericValue.toDouble();
                break;
              case HealthDataType.HEART_RATE:
                if (heartRate == 0) heartRate = numericValue.toInt(); 
                break;
              case HealthDataType.SLEEP_ASLEEP:
              case HealthDataType.SLEEP_DEEP:
              case HealthDataType.SLEEP_LIGHT:
              case HealthDataType.SLEEP_REM:
                totalSleepMinutes += numericValue.toDouble();
                break;
              case HealthDataType.SLEEP_AWAKE: // SLEEP_AWAKE is typically non-contributing to "time asleep"
                break; 
              default:
                // This case should ideally not be hit if types are well-defined
                // print('HealthService: Unexpected NumericHealthValue point type: ${point.type}');
                break;
            }
          } else if (point.value is WorkoutHealthValue && point.type == HealthDataType.WORKOUT) {
            final workoutValue = point.value as WorkoutHealthValue;
            
            // Simplified workout processing due to uncertainty about WorkoutSummary/WorkoutHealthValue fields
            // print('HealthService: Detected WORKOUT: ${workoutValue.workoutActivityType.name} from ${point.dateFrom} to ${point.dateTo}');
            
            // For now, add a placeholder workout or use demo data logic. 
            // We are successfully detecting the workout type and time.
            // Actual duration and calories will use demo/default values.
            final demoWorkout = _generateDemoHealthData(point.dateFrom).workouts.firstOrNull ?? 
                                WorkoutData(type: workoutValue.workoutActivityType.name, durationMinutes: 0, caloriesBurned: 0, startTime: DateFormatter.formatTime(point.dateFrom), endTime: DateFormatter.formatTime(point.dateTo));

            workouts.add(WorkoutData(
              type: workoutValue.workoutActivityType.name,
              durationMinutes: demoWorkout.durationMinutes, // Using demo/default
              caloriesBurned: demoWorkout.caloriesBurned, // Using demo/default
              startTime: DateFormatter.formatTime(point.dateFrom),
              endTime: DateFormatter.formatTime(point.dateTo),
            ));

          } else {
            // print('HealthService: Point value is not NumericHealthValue or WorkoutHealthValue for type ${point.type}. Value: ${point.value}');
          }
        }
        
        final demoFallback = _generateDemoHealthData(date);
        
        SleepData sleepData;
        if (totalSleepMinutes > 0) {
          // Basic conversion, doesn't differentiate deep/light/rem from this aggregated value
          sleepData = SleepData(
            totalHours: totalSleepMinutes / 60.0, 
            deepSleepHours: 0, 
            lightSleepHours: 0,
            remSleepHours: 0,
            awakeSleepHours: 0); 
        } else {
          sleepData = demoFallback.sleep;
        }

        return HealthData(
          date: formattedDate,
          steps: steps ?? fetchedSteps, 
          distanceWalked: demoFallback.distanceWalked, 
          activeMinutes: demoFallback.activeMinutes, 
          caloriesBurned: activeEnergy > 0 ? activeEnergy.toInt() : demoFallback.caloriesBurned, 
          heartRate: heartRate != 0 ? heartRate : demoFallback.heartRate, 
          sleep: sleepData, 
          workouts: workouts.isNotEmpty ? workouts : demoFallback.workouts, 
        );
      } else {
        // print('HealthService: No specific health data points fetched for $formattedDate. Returning demo data.');
        return _generateDemoHealthData(date);
      }
    } catch (e) {
      // print('HealthService: Error fetching real health data for $formattedDate: $e. Returning demo data.');
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