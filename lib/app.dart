import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:behaviormind/providers/settings_provider.dart';
import 'package:behaviormind/routes.dart';
import 'package:behaviormind/theme/app_theme.dart';

class BehaviorMindApp extends StatelessWidget {
  const BehaviorMindApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return MaterialApp(
          title: 'BehaviorMind',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settingsProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: AppRoutes.home,
          onGenerateRoute: AppRouter.generateRoute,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}