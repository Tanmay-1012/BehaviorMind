import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:behaviormind/providers/user_provider.dart';
import 'package:behaviormind/models/user_model.dart';
import 'package:behaviormind/theme/colors.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
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
    if (!_formKey.currentState!.validate()) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;
    
    if (currentUser == null) return;
    
    try {
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
      );
      
      await userProvider.updateUser(updatedUser);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
      
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(
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
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              SizedBox(height: 24.0),
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
              SizedBox(height: 32.0),
              SizedBox(
                width: double.infinity,
                height: 50.0,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  child: Text('Save Changes'),
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
        style: TextStyle(
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
