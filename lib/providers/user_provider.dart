import 'package:flutter/foundation.dart';
import 'package:behaviormind/models/user_model.dart';
import 'package:behaviormind/services/storage_service.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  final StorageService _storageService = StorageService();
  bool _isUserLoaded = false;
  
  User? get user => _user;
  
  bool get isLoggedIn => _user != null;
  
  bool get isUserLoaded => _isUserLoaded;
  
  // Load user data from storage
  Future<void> loadUser() async {
    try {
      final loadedUser = await _storageService.getUser();
      if (loadedUser != null) {
        _user = loadedUser;
      }
    } catch (e) {
      // print("Error loading user: $e");
      // Handle error, maybe set to a default user or null
      _user = null; // Or User.defaultUser() if you have one
    } finally {
      _isUserLoaded = true;
      notifyListeners();
    }
  }
  
  // Set user data (typically after login)
  void setUser(User user) {
    _user = user;
    _isUserLoaded = true;
    _storageService.saveUser(user);
    notifyListeners();
  }
  
  // Update user data
  Future<void> updateUser(User updatedUser) async {
    _user = updatedUser;
    await _storageService.saveUser(updatedUser);
    notifyListeners();
  }
  
  // Update health goals
  Future<void> updateHealthGoals(Map<String, dynamic> healthGoals) async {
    if (_user == null) return;
    
    final updatedUser = _user!.copyWith(healthGoals: healthGoals);
    _user = updatedUser;
    await _storageService.saveUser(updatedUser);
    notifyListeners();
  }
  
  // Clear user data (typically after logout)
  void clearUser() {
    _user = null;
    _isUserLoaded = false;
    notifyListeners();
  }
  
  // Update user profile information
  Future<void> updateProfile({
    String? name,
    int? age,
    String? dateOfBirth,
    String? bloodType,
    int? weight,
    int? height,
  }) async {
    if (_user == null) return;
    
    final updatedUser = _user!.copyWith(
      name: name ?? _user!.name,
      age: age ?? _user!.age,
      dateOfBirth: dateOfBirth ?? _user!.dateOfBirth,
      bloodType: bloodType ?? _user!.bloodType,
      weight: weight ?? _user!.weight,
      height: height ?? _user!.height,
    );
    
    _user = updatedUser;
    await _storageService.saveUser(updatedUser);
    notifyListeners();
  }
  
  // Update profile image
  Future<void> updateProfileImage(String imagePath) async {
    if (_user == null) return;
    
    final updatedUser = _user!.copyWith(profileImage: imagePath);
    _user = updatedUser;
    await _storageService.saveUser(updatedUser);
    notifyListeners();
  }
}
