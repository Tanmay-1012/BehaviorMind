import 'package:behaviormind/models/activity_model.dart';

// Model for sleep data
class SleepData {
  final double totalHours;
  final double deepSleepHours;
  final double lightSleepHours;
  final double remSleepHours;
  final double awakeSleepHours;
  
  SleepData({
    required this.totalHours,
    required this.deepSleepHours,
    required this.lightSleepHours,
    required this.remSleepHours,
    required this.awakeSleepHours,
  });
  
  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'totalHours': totalHours,
      'deepSleepHours': deepSleepHours,
      'lightSleepHours': lightSleepHours,
      'remSleepHours': remSleepHours,
      'awakeSleepHours': awakeSleepHours,
    };
  }
  
  // Create from Map
  factory SleepData.fromMap(Map<String, dynamic> map) {
    return SleepData(
      totalHours: map['totalHours']?.toDouble() ?? 0.0,
      deepSleepHours: map['deepSleepHours']?.toDouble() ?? 0.0,
      lightSleepHours: map['lightSleepHours']?.toDouble() ?? 0.0,
      remSleepHours: map['remSleepHours']?.toDouble() ?? 0.0,
      awakeSleepHours: map['awakeSleepHours']?.toDouble() ?? 0.0,
    );
  }
  
  // Generate demo sleep data
  factory SleepData.demo() {
    return SleepData(
      totalHours: 7.5,
      deepSleepHours: 1.5,
      lightSleepHours: 4.0,
      remSleepHours: 1.5,
      awakeSleepHours: 0.5,
    );
  }
}

// Model for workout data
class WorkoutData {
  final String type;
  final int durationMinutes;
  final int caloriesBurned;
  final String startTime;
  final String endTime;
  
  WorkoutData({
    required this.type,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.startTime,
    required this.endTime,
  });
  
  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
  
  // Create from Map
  factory WorkoutData.fromMap(Map<String, dynamic> map) {
    return WorkoutData(
      type: map['type'] ?? '',
      durationMinutes: map['durationMinutes'] ?? 0,
      caloriesBurned: map['caloriesBurned'] ?? 0,
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
    );
  }
}

// Main health data model
class HealthData {
  final String date;
  final int steps;
  final double distanceWalked; // in km
  final int activeMinutes;
  final int caloriesBurned;
  final int heartRate; // average for the day
  final SleepData sleep;
  final List<WorkoutData> workouts;
  
  HealthData({
    required this.date,
    required this.steps,
    required this.distanceWalked,
    required this.activeMinutes,
    required this.caloriesBurned,
    required this.heartRate,
    required this.sleep,
    required this.workouts,
  });
  
  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'steps': steps,
      'distanceWalked': distanceWalked,
      'activeMinutes': activeMinutes,
      'caloriesBurned': caloriesBurned,
      'heartRate': heartRate,
      'sleep': sleep.toMap(),
      'workouts': workouts.map((workout) => workout.toMap()).toList(),
    };
  }
  
  // Create from Map
  factory HealthData.fromMap(Map<String, dynamic> map) {
    return HealthData(
      date: map['date'] ?? '',
      steps: map['steps'] ?? 0,
      distanceWalked: map['distanceWalked']?.toDouble() ?? 0.0,
      activeMinutes: map['activeMinutes'] ?? 0,
      caloriesBurned: map['caloriesBurned'] ?? 0,
      heartRate: map['heartRate'] ?? 0,
      sleep: SleepData.fromMap(map['sleep'] ?? {}),
      workouts: List<WorkoutData>.from(
        (map['workouts'] ?? []).map((workout) => WorkoutData.fromMap(workout))
      ),
    );
  }
  
  // Generate demo health data for a specific date
  factory HealthData.demoForDate(String date) {
    return HealthData(
      date: date,
      steps: 8500 + DateTime.parse(date).day * 100, // Vary steps by day
      distanceWalked: 5.2 + (DateTime.parse(date).day % 3) * 0.5, // Vary distance
      activeMinutes: 45 + (DateTime.parse(date).day % 4) * 5, // Vary active minutes
      caloriesBurned: 1800 + (DateTime.parse(date).day % 5) * 50, // Vary calories
      heartRate: 68 + (DateTime.parse(date).day % 7), // Vary heart rate
      sleep: SleepData(
        totalHours: 7.0 + (DateTime.parse(date).day % 2),
        deepSleepHours: 1.5 + (DateTime.parse(date).day % 3) * 0.2,
        lightSleepHours: 4.0,
        remSleepHours: 1.0 + (DateTime.parse(date).day % 2) * 0.5,
        awakeSleepHours: 0.5,
      ),
      workouts: [
        if (DateTime.parse(date).weekday == 1 || DateTime.parse(date).weekday == 3 || DateTime.parse(date).weekday == 5)
          WorkoutData(
            type: 'Running',
            durationMinutes: 30,
            caloriesBurned: 350,
            startTime: '07:30',
            endTime: '08:00',
          ),
        if (DateTime.parse(date).weekday == 2 || DateTime.parse(date).weekday == 4)
          WorkoutData(
            type: 'Strength Training',
            durationMinutes: 45,
            caloriesBurned: 280,
            startTime: '18:00',
            endTime: '18:45',
          ),
        if (DateTime.parse(date).weekday == 6)
          WorkoutData(
            type: 'Cycling',
            durationMinutes: 60,
            caloriesBurned: 450,
            startTime: '10:00',
            endTime: '11:00',
          ),
      ],
    );
  }
}

