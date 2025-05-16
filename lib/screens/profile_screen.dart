import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:behaviormind/providers/user_provider.dart';
import 'package:behaviormind/routes.dart';
import 'package:behaviormind/theme/colors.dart';
import 'package:behaviormind/widgets/edit_profile_dialog.dart';
import 'package:behaviormind/widgets/edit_health_goals_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3;
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Navigate to the appropriate screen based on the selected index
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.predict);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.archive);
        break;
      case 3:
        // Already on profile screen
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
        ],
      ),
      body: user == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile header
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primary.withOpacity(0.2),
                            backgroundImage: AssetImage(user.profileImage),
                            child: user.profileImage.isEmpty 
                                ? Icon(Icons.person, size: 50, color: AppColors.primary) 
                                : null,
                          ),
                          GestureDetector(
                            onTap: () {
                              _showChangeProfilePhotoDialog(context, userProvider);
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                  
                  // Personal Info Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Personal Information',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              IconButton(
                                icon: Icon(Icons.edit_outlined),
                                onPressed: () {
                                  _showEditProfileDialog(context, userProvider);
                                },
                              ),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          
                          _buildInfoItem(
                            context, 
                            'Age', 
                            '${user.age} years',
                            Icons.cake_outlined,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoItem(
                            context, 
                            'Date of Birth', 
                            user.dateOfBirth,
                            Icons.calendar_today_outlined,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoItem(
                            context, 
                            'Height', 
                            '${user.height} cm',
                            Icons.height_outlined,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoItem(
                            context, 
                            'Weight', 
                            '${user.weight} kg',
                            Icons.fitness_center_outlined,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoItem(
                            context, 
                            'Blood Type', 
                            user.bloodType,
                            Icons.bloodtype_outlined,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Health Goals Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Health Goals',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              IconButton(
                                icon: Icon(Icons.edit_outlined),
                                onPressed: () {
                                  _showEditHealthGoalsDialog(context, userProvider);
                                },
                              ),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          
                          _buildGoalItem(
                            context, 
                            'Daily Steps', 
                            user.healthGoals['steps']?.toString() ?? '10,000',
                            Icons.directions_walk_outlined,
                            AppColors.primary,
                          ),
                          const SizedBox(height: 12),
                          _buildGoalItem(
                            context, 
                            'Sleep', 
                            '${user.healthGoals['sleep']?.toString() ?? '8'} hours',
                            Icons.nightlight_round,
                            AppColors.secondary,
                          ),
                          const SizedBox(height: 12),
                          _buildGoalItem(
                            context, 
                            'Water', 
                            '${user.healthGoals['water']?.toString() ?? '8'} glasses',
                            Icons.water_drop_outlined,
                            Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          _buildGoalItem(
                            context, 
                            'Meditation', 
                            '${user.healthGoals['meditation']?.toString() ?? '15'} minutes',
                            Icons.self_improvement_outlined,
                            Colors.purple,
                          ),
                          const SizedBox(height: 12),
                          _buildGoalItem(
                            context, 
                            'Calories', 
                            '${user.healthGoals['calories']?.toString() ?? '2,000'} kcal',
                            Icons.local_fire_department_outlined,
                            Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Connected Devices Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Connected Devices',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              IconButton(
                                icon: Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  // Add device
                                },
                              ),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          
                          if (user.connectedDevices.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Text(
                                'No devices connected yet',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            )
                          else
                            ...user.connectedDevices.map((device) => 
                              _buildDeviceItem(context, device)
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Account actions section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Account',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Sign out button
                  InkWell(
                    onTap: () {
                      // Handle sign out
                      userProvider.clearUser();
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout_outlined,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Sign Out',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_outlined),
            activeIcon: Icon(Icons.insights),
            label: 'Predict',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.archive_outlined),
            activeIcon: Icon(Icons.archive),
            label: 'Archive',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
  
  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildGoalItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDeviceItem(BuildContext context, String device) {
    IconData deviceIcon;
    
    if (device.toLowerCase().contains('fitbit')) {
      deviceIcon = Icons.watch_outlined;
    } else if (device.toLowerCase().contains('samsung')) {
      deviceIcon = Icons.watch_outlined;
    } else if (device.toLowerCase().contains('apple')) {
      deviceIcon = Icons.watch_outlined;
    } else if (device.toLowerCase().contains('garmin')) {
      deviceIcon = Icons.watch_outlined;
    } else {
      deviceIcon = Icons.smartphone;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(deviceIcon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            device,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          Text(
            'Connected',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showEditProfileDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(
        user: userProvider.user!,
        onSave: (updatedUser) {
          userProvider.updateUser(updatedUser);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );
  }
  
  void _showEditHealthGoalsDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => EditHealthGoalsDialog(
        user: userProvider.user!,
        onSave: (updatedHealthGoals) {
          userProvider.updateHealthGoals(updatedHealthGoals);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Health goals updated successfully'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        },
      ),
    );
  }
  
  void _showChangeProfilePhotoDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Change Profile Photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: AppColors.primary),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _selectImageFromGallery(context, userProvider);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColors.primary),
                title: Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto(context, userProvider);
                },
              ),
              if (userProvider.user!.profileImage.isNotEmpty) 
                Column(
                  children: [
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Remove Current Photo'),
                      onTap: () {
                        Navigator.pop(context);
                        _removeProfilePhoto(context, userProvider);
                      },
                    ),
                  ],
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
  
  void _selectImageFromGallery(BuildContext context, UserProvider userProvider) {
    // This is a placeholder for the image picker functionality
    // In a real app, you would use image_picker package
    // and implement the actual selection process
    
    // For demonstration purposes, we'll just update the profile with a predefined image
    String newProfileImage = 'assets/images/profile_default.png';
    
    userProvider.updateProfileImage(newProfileImage);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile photo updated successfully'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
  
  void _takePhoto(BuildContext context, UserProvider userProvider) {
    // This is a placeholder for the camera functionality
    // In a real app, you would use image_picker package with camera source
    
    // For demonstration purposes, we'll just update the profile with a predefined image
    String newProfileImage = 'assets/images/profile_default.png';
    
    userProvider.updateProfileImage(newProfileImage);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile photo updated successfully'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
  
  void _removeProfilePhoto(BuildContext context, UserProvider userProvider) {
    // Set an empty profile image path
    userProvider.updateProfileImage('');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile photo removed'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}