import 'dart:io'; // For File
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart'; // Added import
import 'package:path/path.dart' as path; // Added import for path manipulation
import 'package:behaviormind/providers/user_provider.dart';
import 'package:behaviormind/theme/colors.dart';
import 'package:behaviormind/providers/settings_provider.dart'; // Added for settings

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _bloodTypeController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _dailyStepsController;
  late TextEditingController _weeklyWorkoutsController;
  late TextEditingController _sleepGoalController;

  File? _profileImageFile; // To store the picked image file

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    
    if (user != null) {
      _nameController = TextEditingController(text: user.name);
      _ageController = TextEditingController(text: user.age.toString());
      _dateOfBirthController = TextEditingController(text: user.dateOfBirth);
      _bloodTypeController = TextEditingController(text: user.bloodType);
      _weightController = TextEditingController(text: user.weight.toString());
      _heightController = TextEditingController(text: user.height.toString());
      
      final healthGoals = user.healthGoals;
      _dailyStepsController = TextEditingController(
        text: (healthGoals['dailySteps']?['target'] ?? 10000).toString(),
      );
      _weeklyWorkoutsController = TextEditingController(
        text: (healthGoals['weeklyWorkouts']?['target'] ?? 4).toString(),
      );
      _sleepGoalController = TextEditingController(
        text: (healthGoals['sleepGoal']?['target'] ?? 8).toString(),
      );
    } else {
      _nameController = TextEditingController();
      _ageController = TextEditingController();
      _dateOfBirthController = TextEditingController();
      _bloodTypeController = TextEditingController();
      _weightController = TextEditingController();
      _heightController = TextEditingController();
      _dailyStepsController = TextEditingController();
      _weeklyWorkoutsController = TextEditingController();
      _sleepGoalController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _dateOfBirthController.dispose();
    _bloodTypeController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _dailyStepsController.dispose();
    _weeklyWorkoutsController.dispose();
    _sleepGoalController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      // print("Form validation failed."); // Commented out
      return;
    }
    // print("Form validated. Proceeding to save profile."); // Commented out

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;
    
    if (currentUser == null) {
      // print("Cannot save profile, current user is null."); // Commented out
      return;
    }
    
    String? newProfileImagePath = currentUser.profileImage; 
    // bool imageUpdated = false; // REMOVED - UNUSED if _pickImage and its dependent logic are gone
    if (_profileImageFile != null) {
      // print("New profile image file is present: ${_profileImageFile!.path}"); // Commented out
      try {
        final documentsDir = await getApplicationDocumentsDirectory();
        final fileName = path.basename(_profileImageFile!.path);
        final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
        final savedImage = await _profileImageFile!.copy('${documentsDir.path}/$uniqueFileName');
        newProfileImagePath = savedImage.path;
        // imageUpdated = true;
        // print("New profile image successfully saved to: $newProfileImagePath"); // Commented out
      } catch (e) {
        // print("Error saving profile image to documents directory: $e"); // Commented out
        if (mounted) {
          final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
          if (settingsProvider.inAppAlerts) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to save profile image: ${e.toString()}')),
            );
          }
        }
      }
    } else {
      // print("No new profile image file was selected to save."); // Commented out
    }

    try {
      // print("Preparing to update user model..."); // Commented out
      final healthGoals = {
        'dailySteps': {
          'current': currentUser.healthGoals['dailySteps']?['current'] ?? 0,
          'target': int.parse(_dailyStepsController.text),
        },
        'weeklyWorkouts': {
          'current': currentUser.healthGoals['weeklyWorkouts']?['current'] ?? 0,
          'target': int.parse(_weeklyWorkoutsController.text),
        },
        'sleepGoal': {
          'current': currentUser.healthGoals['sleepGoal']?['current'] ?? 0,
          'target': int.parse(_sleepGoalController.text),
        },
      };
      
      final updatedUser = currentUser.copyWith(
        name: _nameController.text,
        age: int.parse(_ageController.text),
        dateOfBirth: _dateOfBirthController.text,
        bloodType: _bloodTypeController.text,
        weight: int.parse(_weightController.text),
        height: int.parse(_heightController.text),
        healthGoals: healthGoals,
        profileImage: newProfileImagePath,
      );
      
      await userProvider.updateUser(updatedUser);
      _profileImageFile = null; // Clear the picked file after saving

      if (mounted) {
        // print("--- DEBUG_SAVE_PROFILE: Profile updated successfully. Navigating back. ---"); // Commented out
        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
        if (settingsProvider.inAppAlerts) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
        // if (Navigator.of(context).canPop()) { // TEMPORARILY COMMENTING OUT THE POP
        //     Navigator.of(context).pop();
        // }
      }
    } catch (e) {
      // print("Error updating profile: $e"); // Commented out
      if (mounted) {
        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
        if (settingsProvider.inAppAlerts) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final user = Provider.of<UserProvider>(context).user; // listen: true to see updates
    // It's safer to use a Consumer or Selector if only parts of the UI depend on user
    // or ensure that listen:true is appropriate for the whole build method.
    // For _determineBackgroundImage, it needs the user.

    ImageProvider determineBackgroundImage(String? imagePath, UserProvider userProvider) { // RENAMED
      // print("--- DEBUG_DETERMINE_BACKGROUND_IMAGE: imagePath: '$imagePath' ---"); // Commented out
      if (_profileImageFile != null) {
        // print("--- DEBUG_DETERMINE_BACKGROUND_IMAGE: Using _profileImageFile: ${_profileImageFile!.path} ---"); // Commented out
        return FileImage(_profileImageFile!);
      }
      if (imagePath != null && imagePath.isNotEmpty) {
        if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
          // print("--- DEBUG_DETERMINE_BACKGROUND_IMAGE: Using NetworkImage for: $imagePath ---"); // Commented out
          return NetworkImage(imagePath);
        } else if (path.isAbsolute(imagePath)) { // Check if it's a local file path
          // print("--- DEBUG_DETERMINE_BACKGROUND_IMAGE: Using FileImage for local path: $imagePath ---"); // Commented out
          return FileImage(File(imagePath));
        } else if (imagePath == 'assets/images/profile_default.png') {
           // print("--- DEBUG_DETERMINE_BACKGROUND_IMAGE: Using AssetImage for default: $imagePath ---"); // Commented out
           return const AssetImage('assets/images/profile_default.png');
        }
      }
      // print("--- DEBUG_DETERMINE_BACKGROUND_IMAGE: Falling back to userProvider or default AssetImage ---"); // Commented out
      final user = userProvider.user;
      if (user != null && user.profileImage.isNotEmpty) {
         if (user.profileImage.startsWith('http') || user.profileImage.startsWith('https')) {
          // print("--- DEBUG_DETERMINE_BACKGROUND_IMAGE: Fallback Network: ${user.profileImage} ---"); // Commented out
          return NetworkImage(user.profileImage);
        } else if (path.isAbsolute(user.profileImage)) {
          // print("--- DEBUG_DETERMINE_BACKGROUND_IMAGE: Fallback File: ${user.profileImage} ---"); // Commented out
          return FileImage(File(user.profileImage));
        }
      }
      // print("--- DEBUG_DETERMINE_BACKGROUND_IMAGE: Using final fallback default AssetImage ---"); // Commented out
      return const AssetImage('assets/images/profile_default.png'); 
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // print("--- DEBUG_APPBAR_BACK_BUTTON: Tapped! ---"); // Commented out
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () {
                    // print("--- DEBUG_PROFILE_IMAGE_TAP: CircleAvatar tapped! (Action sheet call commented out) ---"); // COMMENTED OUT
                    // print("Profile image tapped. Showing image source action sheet. (Call is COMMENTED OUT)"); // COMMENTED OUT
                    // _showImageSourceActionSheet(context); // Temporarily commented out
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: determineBackgroundImage(Provider.of<UserProvider>(context, listen: true).user?.profileImage, Provider.of<UserProvider>(context, listen: true)), 
                    child: determineBackgroundImage(Provider.of<UserProvider>(context, listen: true).user?.profileImage, Provider.of<UserProvider>(context, listen: true)) is AssetImage && _profileImageFile == null && (Provider.of<UserProvider>(context, listen: true).user?.profileImage == null || Provider.of<UserProvider>(context, listen: true).user?.profileImage == 'assets/images/profile_default.png')
                        ? Icon(Icons.person, color: Colors.grey.shade700, size: 50) 
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Personal Information'),
              _buildTextField(
                controller: _nameController,
                label: 'Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _ageController,
                label: 'Age',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _dateOfBirthController,
                label: 'Date of Birth',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your date of birth';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _bloodTypeController,
                label: 'Blood Type',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your blood type';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _weightController,
                label: 'Weight (kg)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _heightController,
                label: 'Height (cm)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your height';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              _buildSectionTitle('Health Goals'),
              _buildTextField(
                controller: _dailyStepsController,
                label: 'Daily Steps Target',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your daily steps target';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _weeklyWorkoutsController,
                label: 'Weekly Workouts Target',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weekly workouts target';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _sleepGoalController,
                label: 'Sleep Goal (hours)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your sleep goal';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),
              SizedBox(
                width: double.infinity,
                height: 50.0,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        validator: validator,
      ),
    );
  }
}
