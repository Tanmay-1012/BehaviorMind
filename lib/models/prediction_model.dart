// Point class for chart visualization of predictions
class PredictionPoint {
  final String day;
  final double actual;
  final double predicted;

  PredictionPoint({
    required this.day,
    required this.actual,
    required this.predicted,
  });
}

// Main prediction model class
class Prediction {
  final String id;
  final String date;
  final Map<String, List<double>> activityPrediction; // e.g. {'Mon': [actual, predicted], 'Tue': [...]}
  final List<String> insights;
  final List<String> recommendations;
  final String mentalFatiguePrediction;
  final double predictionAccuracy;
  final Map<String, double> factorCorrelations;

  Prediction({
    required this.id,
    required this.date,
    required this.activityPrediction,
    required this.insights,
    required this.recommendations,
    required this.mentalFatiguePrediction,
    required this.predictionAccuracy,
    required this.factorCorrelations,
  });

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'activityPrediction': activityPrediction,
      'insights': insights,
      'recommendations': recommendations,
      'mentalFatiguePrediction': mentalFatiguePrediction,
      'predictionAccuracy': predictionAccuracy,
      'factorCorrelations': factorCorrelations,
    };
  }

  // Create from Map
  factory Prediction.fromMap(Map<String, dynamic> map) {
    return Prediction(
      id: map['id'] ?? '',
      date: map['date'] ?? '',
      activityPrediction: Map<String, List<double>>.from(
        (map['activityPrediction'] ?? {}).map(
          (key, value) => MapEntry(key, List<double>.from(value)),
        ),
      ),
      insights: List<String>.from(map['insights'] ?? []),
      recommendations: List<String>.from(map['recommendations'] ?? []),
      mentalFatiguePrediction: map['mentalFatiguePrediction'] ?? '',
      predictionAccuracy: map['predictionAccuracy']?.toDouble() ?? 0.0,
      factorCorrelations: Map<String, double>.from(
        (map['factorCorrelations'] ?? {}).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
    );
  }

  // Generate demo prediction for testing
  factory Prediction.demo() {
    return Prediction(
      id: 'pred-${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now().toString().split(' ')[0],
      activityPrediction: {
        'Mon': [6300.0, 6000.0],
        'Tue': [5800.0, 6100.0],
        'Wed': [6500.0, 6300.0],
        'Thu': [6000.0, 6200.0],
        'Fri': [7200.0, 6800.0],
        'Sat': [6900.0, 7000.0],
        'Sun': [5500.0, 6000.0],
      },
      insights: [
        'Your activity levels peak on Fridays and Saturdays',
        'Lower activity on Sundays may indicate need for more rest',
        'Screen time before bed correlates with reduced sleep quality',
        'Consistent morning walks improve your reported mood',
      ],
      recommendations: [
        'Consider a brief walk on Sunday afternoons',
        'Reduce screen time 1 hour before sleep',
        'Maintain your consistent morning activity schedule',
        'Consider adding a brief meditation session on high-stress days',
      ],
      mentalFatiguePrediction: 'Based on the data, there\'s a moderate risk of mental fatigue. The combination of high social media consumption, reported afternoon stress, and potentially suboptimal sleep patterns (light sleep is dominant) suggests that the user may be experiencing cognitive strain. Further monitoring and potential adjustments to their routine, especially regarding social media usage and sleep hygiene, are recommended to mitigate the risk of developing significant mental fatigue.',
      predictionAccuracy: 0.85,
      factorCorrelations: {
        'sleepQuality': 0.72,
        'screenTime': -0.68,
        'exerciseMinutes': 0.64,
        'socialInteraction': 0.55,
        'outdoorTime': 0.61,
      },
    );
  }
}