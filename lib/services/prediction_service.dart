import 'dart:math';
import 'package:behaviormind/models/health_data_model.dart';
import 'package:behaviormind/models/prediction_model.dart';
import 'package:behaviormind/utils/date_formatter.dart';

class PredictionService {
  // Generate prediction based on health data
  Future<Prediction> generatePrediction(List<HealthData> healthData) async {
    // In a real app, this would use TensorFlow Lite to analyze the data
    // and generate predictions based on the user's behavior pattern
    
    // Generate a unique ID for this prediction
    final id = 'pred-${DateTime.now().millisecondsSinceEpoch}';
    
    // Current date formatted as ISO
    final date = DateFormatter.formatIso(DateTime.now());
    
    // Process health data to create prediction
    final activityPrediction = _generateActivityPrediction(healthData);
    final insights = _generateInsights(healthData);
    final recommendations = _generateRecommendations(healthData);
    final mentalFatiguePrediction = _generateMentalFatiguePrediction(healthData);
    final correlations = _generateFactorCorrelations(healthData);
    
    // Create and return the prediction
    return Prediction(
      id: id,
      date: date,
      activityPrediction: activityPrediction,
      insights: insights,
      recommendations: recommendations,
      mentalFatiguePrediction: mentalFatiguePrediction,
      predictionAccuracy: 0.85, // Placeholder for accuracy metric
      factorCorrelations: correlations,
    );
  }
  
  // Generate activity prediction for each day of the week
  Map<String, List<double>> _generateActivityPrediction(List<HealthData> healthData) {
    // Days of the week
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final random = Random();
    
    // Map to store actual and predicted values for each day
    final activityPrediction = <String, List<double>>{};
    
    // Base step count from historical data
    final baseSteps = healthData.isEmpty 
        ? 6000.0
        : healthData.map((data) => data.steps).reduce((a, b) => a + b) / healthData.length;
    
    // Generate for each day
    for (int i = 0; i < days.length; i++) {
      final day = days[i];
      
      // Generate actual value (historical data)
      final actualVariation = (random.nextDouble() * 1000) - 500; // +/- 500 steps
      final actual = baseSteps + actualVariation;
      
      // Generate predicted value with slight variance
      final predictionVariation = (random.nextDouble() * 800) - 400; // +/- 400 steps
      final predicted = baseSteps + predictionVariation;
      
      // Store values
      activityPrediction[day] = [actual, predicted];
    }
    
    return activityPrediction;
  }
  
  // Generate insights based on health data
  List<String> _generateInsights(List<HealthData> healthData) {
    if (healthData.isEmpty) {
      return [
        'Insufficient data to generate detailed insights',
        'Continue tracking your activity to receive personalized insights',
      ];
    }
    
    final random = Random();
    final insights = <String>[];
    
    // Analyze sleep patterns
    final averageSleep = healthData
        .map((data) => data.sleep.totalHours)
        .reduce((a, b) => a + b) / healthData.length;
    
    if (averageSleep < 7.0) {
      insights.add('Your average sleep duration of ${averageSleep.toStringAsFixed(1)} hours is below the recommended 7-9 hours');
    } else {
      insights.add('Your average sleep duration of ${averageSleep.toStringAsFixed(1)} hours falls within the recommended range');
    }
    
    // Analyze activity patterns
    final highestStepsDay = healthData.reduce((a, b) => a.steps > b.steps ? a : b);
    final lowestStepsDay = healthData.reduce((a, b) => a.steps < b.steps ? a : b);
    
    insights.add('Your activity levels peak on ${DateFormatter.getDayOfWeekFromIso(highestStepsDay.date)}s and are lowest on ${DateFormatter.getDayOfWeekFromIso(lowestStepsDay.date)}s');
    
    // Additional generic insights
    final additionalInsights = [
      'Screen time before bed correlates with reduced sleep quality',
      'Consistent morning walks improve your reported mood',
      'Higher step counts on weekdays correlate with better sleep quality',
      'Your heart rate variability improves on days with moderate exercise',
      'Periods of prolonged sitting are detected between 2-4 PM on workdays',
    ];
    
    // Add 2-3 random additional insights
    additionalInsights.shuffle();
    insights.addAll(additionalInsights.take(2));
    
    return insights;
  }
  
  // Generate recommendations based on health data
  List<String> _generateRecommendations(List<HealthData> healthData) {
    if (healthData.isEmpty) {
      return [
        'Track your activity regularly to receive personalized recommendations',
        'Set up health goals in the profile section',
      ];
    }
    
    final recommendations = <String>[];
    
    // Analyze sleep patterns
    final averageSleep = healthData
        .map((data) => data.sleep.totalHours)
        .reduce((a, b) => a + b) / healthData.length;
    
    if (averageSleep < 7.0) {
      recommendations.add('Aim for 7-8 hours of sleep by establishing a consistent bedtime routine');
    }
    
    // Analyze step counts
    final lowestStepsDay = healthData.reduce((a, b) => a.steps < b.steps ? a : b);
    recommendations.add('Consider a brief walk on ${DateFormatter.getDayOfWeekFromIso(lowestStepsDay.date)} afternoons');
    
    // Additional generic recommendations
    final additionalRecommendations = [
      'Reduce screen time 1 hour before sleep',
      'Maintain your consistent morning activity schedule',
      'Consider adding a brief meditation session on high-stress days',
      'Try to break up long sitting periods with short 2-minute movement breaks',
      'Schedule higher intensity workouts at least 3 hours before bedtime',
      'Increase water intake during midday hours when your hydration typically dips',
    ];
    
    // Add 2-3 random additional recommendations
    additionalRecommendations.shuffle();
    recommendations.addAll(additionalRecommendations.take(3));
    
    return recommendations;
  }
  
  // Generate mental fatigue prediction
  String _generateMentalFatiguePrediction(List<HealthData> healthData) {
    if (healthData.isEmpty) {
      return 'Insufficient data to generate mental fatigue prediction. Continue tracking your activity patterns to receive this insight.';
    }
    
    // In a real app, this would be based on ML model analysis
    // For this demo, we'll return a placeholder prediction
    return 'Based on the data, there\'s a moderate risk of mental fatigue. The combination of high social media consumption, reported afternoon stress, and potentially suboptimal sleep patterns (light sleep is dominant) suggests that the user may be experiencing cognitive strain. Further monitoring and potential adjustments to their routine, especially regarding social media usage and sleep hygiene, are recommended to mitigate the risk of developing significant mental fatigue.';
  }
  
  // Generate factor correlations
  Map<String, double> _generateFactorCorrelations(List<HealthData> healthData) {
    // In a real app, these would be calculated from actual correlations
    // For this demo, we'll use placeholder values
    return {
      'sleepQuality': 0.72,
      'screenTime': -0.68,
      'exerciseMinutes': 0.64,
      'socialInteraction': 0.55,
      'outdoorTime': 0.61,
    };
  }
}