import 'package:behaviormind/models/user_model.dart';
import 'package:behaviormind/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final StorageService _storageService = StorageService();

  // Login user
  Future<User?> login(String email, String password) async {
    // This is a demo implementation
    if (email == 'demo@example.com' && password == 'password123') {
      final user = User(
        id: '1',
        email: 'demo@example.com',
        name: 'Demo User',
        age: 30,
        dateOfBirth: 'January 1, 1994',
        bloodType: 'O+',
        weight: 70,
        height: 170,
        healthGoals: {
          'dailySteps': {
            'current': 8000,
            'target': 10000,
          },
          'weeklyWorkouts': {
            'current': 3,
            'target': 4,
          },
          'sleepGoal': {
            'current': 7,
            'target': 8,
          },
        },
      );
      
      // Save login status and user data
      await _saveAuthState(true);
      await _storageService.saveUser(user);
      
      return user;
    }
    
    return null;
  }

  // Logout user
  Future<void> logout() async {
    await _saveAuthState(false);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // Save authentication state
  Future<void> _saveAuthState(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }
}
