import 'package:flutter/foundation.dart';
import 'package:behaviormind/models/prediction_model.dart';
import 'package:behaviormind/models/health_data_model.dart';
import 'package:behaviormind/providers/health_data_provider.dart';
import 'package:behaviormind/services/prediction_service.dart';
import 'package:behaviormind/services/storage_service.dart';

class PredictionProvider with ChangeNotifier {
  List<Prediction> _predictions = [];
  final PredictionService _predictionService = PredictionService();
  final StorageService _storageService = StorageService();
  
  List<Prediction> get predictions => List.unmodifiable(_predictions);
  
  Prediction? get latestPrediction => 
      _predictions.isNotEmpty ? _predictions.last : null;
  
  // Weekly prediction points for chart
  List<PredictionPoint> get weeklyPredictionPoints {
    if (latestPrediction == null) return [];
    
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    List<PredictionPoint> points = [];
    
    for (final day in days) {
      if (latestPrediction!.activityPrediction.containsKey(day)) {
        final values = latestPrediction!.activityPrediction[day]!;
        
        if (values.length >= 2) {
          points.add(PredictionPoint(
            day: day,
            actual: values[0],
            predicted: values[1],
          ));
        }
      }
    }
    
    return points;
  }
  
  // Load predictions from storage
  Future<void> loadPredictions() async {
    try {
      final storedPredictions = await _storageService.getPredictions();
      
      if (storedPredictions.isNotEmpty) {
        _predictions = storedPredictions;
        notifyListeners();
      } else {
        // Generate initial prediction if none exists
        await generatePrediction();
      }
    } catch (e) {
      print('Error loading predictions: $e');
    }
  }
  
  // Generate new prediction based on health data
  Future<void> generatePrediction() async {
    try {
      // Create a temporary HealthDataProvider to get health data
      // In a real app, this would be injected via constructor
      final healthDataProvider = HealthDataProvider();
      await healthDataProvider.loadHealthData();
      
      // Use the last 7 days of health data
      final healthData = healthDataProvider.healthData;
      
      if (healthData.isEmpty) {
        print('No health data available for prediction');
        return;
      }
      
      // Generate prediction using the service
      final newPrediction = await _predictionService.generatePrediction(healthData);
      
      // Add new prediction to the list
      _predictions.add(newPrediction);
      
      // Save predictions to storage
      await _storageService.savePredictions(_predictions);
      
      notifyListeners();
    } catch (e) {
      print('Error generating prediction: $e');
    }
  }
  
  // Get prediction by date
  Prediction? getPredictionByDate(String date) {
    return _predictions.firstWhere(
      (prediction) => prediction.date == date,
      orElse: () => null as Prediction,
    );
  }
  
  // Get latest insights and recommendations
  List<String> get latestInsights => 
      latestPrediction?.insights ?? [];
  
  List<String> get latestRecommendations => 
      latestPrediction?.recommendations ?? [];
  
  // Get fatigue prediction
  String get mentalFatiguePrediction => 
      latestPrediction?.mentalFatiguePrediction ?? '';
  
  // Check if new prediction is needed
  bool isPredictionNeeded() {
    if (_predictions.isEmpty) return true;
    
    final latestDate = DateTime.parse(_predictions.last.date);
    final today = DateTime.now();
    
    // Need new prediction if latest is more than 1 day old
    return today.difference(latestDate).inDays > 1;
  }
}
