import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:behaviormind/app.dart';
import 'package:behaviormind/providers/user_provider.dart';
import 'package:behaviormind/providers/health_data_provider.dart';
import 'package:behaviormind/providers/prediction_provider.dart';
import 'package:behaviormind/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize providers
  final userProvider = UserProvider();
  await userProvider.loadUser();
  
  final healthDataProvider = HealthDataProvider();
  await healthDataProvider.initialize();
  
  final predictionProvider = PredictionProvider();
  await predictionProvider.loadPredictions();
  
  final settingsProvider = SettingsProvider();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => userProvider),
        ChangeNotifierProvider(create: (_) => healthDataProvider),
        ChangeNotifierProvider(create: (_) => predictionProvider),
        ChangeNotifierProvider(create: (_) => settingsProvider),
      ],
      child: BehaviorMindApp(),
    ),
  );
}