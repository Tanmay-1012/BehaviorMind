import 'package:flutter/material.dart';

enum MoodType {
  positive,
  negative,
  neutral,
  mixed,
}

extension MoodTypeExtension on MoodType {
  String get displayName {
    switch (this) {
      case MoodType.positive:
        return 'Positive Mood';
      case MoodType.negative:
        return 'Negative Mood';
      case MoodType.neutral:
        return 'Neutral Mood';
      case MoodType.mixed:
        return 'Mixed Mood';
    }
  }

  IconData get icon {
    switch (this) {
      case MoodType.positive:
        return Icons.sentiment_satisfied_alt;
      case MoodType.negative:
        return Icons.sentiment_dissatisfied;
      case MoodType.neutral:
        return Icons.sentiment_neutral;
      case MoodType.mixed:
        return Icons.sentiment_neutral;
    }
  }
}

class DailyActivity {
  final String date;
  final int steps;
  final double screenTimeHours;
  final MoodType mood;
  final Map<String, dynamic> prediction;
  final List<String> suggestions;
  final Map<String, bool> suggestionsFollowed;

  DailyActivity({
    required this.date,
    required this.steps,
    required this.screenTimeHours,
    required this.mood,
    required this.prediction,
    required this.suggestions,
    required this.suggestionsFollowed,
  });

  factory DailyActivity.fromJson(Map<String, dynamic> json) {
    return DailyActivity(
      date: json['date'] ?? '',
      steps: json['steps'] ?? 0,
      screenTimeHours: (json['screenTimeHours'] ?? 0).toDouble(),
      mood: MoodType.values.firstWhere(
        (m) => m.toString() == 'MoodType.${json['mood']}',
        orElse: () => MoodType.neutral,
      ),
      prediction: json['prediction'] ?? {},
      suggestions: List<String>.from(json['suggestions'] ?? []),
      suggestionsFollowed: Map<String, bool>.from(json['suggestionsFollowed'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'steps': steps,
      'screenTimeHours': screenTimeHours,
      'mood': mood.toString().split('.').last,
      'prediction': prediction,
      'suggestions': suggestions,
      'suggestionsFollowed': suggestionsFollowed,
    };
  }
  
  // For backward compatibility with code that uses toMap
  Map<String, dynamic> toMap() {
    return toJson();
  }
  
  // For backward compatibility with code that uses fromMap
  factory DailyActivity.fromMap(Map<String, dynamic> map) {
    return DailyActivity.fromJson(map);
  }
  
  // Generate demo daily activity for testing
  factory DailyActivity.demo(String date) {
    final dayOfWeek = DateTime.parse(date).weekday;
    
    // Different moods for different days
    final moodMap = {
      1: MoodType.positive, // Monday
      2: MoodType.neutral, // Tuesday
      3: MoodType.negative, // Wednesday
      4: MoodType.mixed, // Thursday
      5: MoodType.positive, // Friday
      6: MoodType.positive, // Saturday
      7: MoodType.neutral, // Sunday
    };
    
    // Predictions based on day of week
    Map<String, dynamic> prediction;
    
    switch (dayOfWeek) {
      case 1: // Monday
        prediction = {'type': 'focus', 'message': 'Predicted high focus for morning tasks.'};
        break;
      case 2: // Tuesday
        prediction = {'type': 'slump', 'message': 'Potential for afternoon slump.'};
        break;
      case 3: // Wednesday
        prediction = {'type': 'activity', 'message': 'Likely to exceed step goal.'};
        break;
      case 4: // Thursday
        prediction = {'type': 'relaxation', 'message': 'Evening relaxation period identified.'};
        break;
      case 5: // Friday
        prediction = {'type': 'screen', 'message': 'Risk of high screen time before bed.'};
        break;
      default: // Weekend
        prediction = {'type': 'general', 'message': 'Average activity expected today.'};
    }
    
    // Suggestions based on day of week
    List<String> suggestions = [];
    Map<String, bool> suggestionsFollowed = {};
    
    switch (dayOfWeek) {
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
    
    return DailyActivity(
      date: date,
      steps: 7500 + (dayOfWeek * 500), // Vary steps by day of week
      screenTimeHours: 1.5 + (dayOfWeek * 0.5), // Vary screen time
      mood: moodMap[dayOfWeek] ?? MoodType.neutral,
      prediction: prediction,
      suggestions: suggestions,
      suggestionsFollowed: suggestionsFollowed,
    );
  }
}
