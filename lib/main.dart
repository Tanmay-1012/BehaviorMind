import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:behaviormind/app.dart';
import 'package:behaviormind/providers/user_provider.dart';
import 'package:behaviormind/providers/health_data_provider.dart';
import 'package:behaviormind/providers/prediction_provider.dart';
import 'package:behaviormind/providers/settings_provider.dart';
import 'package:behaviormind/routes.dart'; // AppRoutes is needed here

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize providers that don't depend on permissions screen's immediate outcome
  final userProvider = UserProvider();
  // userProvider.loadUser() will be called by PermissionScreen if needed
  
  final healthDataProvider = HealthDataProvider();
  // healthDataProvider.initialize() will be effectively handled by HealthService in PermissionScreen
  
  final predictionProvider = PredictionProvider();
  await predictionProvider.loadPredictions(); // Assuming this can run before user/health is fully ready
  
  final settingsProvider = SettingsProvider();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => userProvider),
        ChangeNotifierProvider(create: (_) => healthDataProvider),
        ChangeNotifierProvider(create: (_) => predictionProvider),
        ChangeNotifierProvider(create: (_) => settingsProvider),
      ],
      child: const BehaviorMindApp(initialRoute: AppRoutes.permissions), // Start with PermissionScreen
    ),
  );
}