import 'package:flutter/material.dart';
import 'package:behaviormind/screens/home_screen.dart';
import 'package:behaviormind/screens/predict_screen.dart';
import 'package:behaviormind/screens/archive_screen.dart';
import 'package:behaviormind/screens/profile_screen.dart';
import 'package:behaviormind/screens/settings_screen.dart';
import 'package:behaviormind/screens/login_screen.dart';
import 'package:behaviormind/screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String predict = '/predict';
  static const String archive = '/archive';
  static const String profile = '/profile';
  static const String settings = '/settings';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.predict:
        return MaterialPageRoute(builder: (_) => const PredictScreen());
      case AppRoutes.archive:
        return MaterialPageRoute(builder: (_) => const ArchiveScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}