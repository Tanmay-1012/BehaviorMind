import 'dart:io'; // For File
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:behaviormind/providers/user_provider.dart';
import 'package:behaviormind/routes.dart';
import 'package:behaviormind/theme/colors.dart';
import 'package:behaviormind/widgets/edit_profile_dialog.dart';
import 'package:behaviormind/widgets/edit_health_goals_dialog.dart';
import 'package:path/path.dart' as path; // Added import for path manipulation
import 'package:image_picker/image_picker.dart'; // Added for image picking
import 'package:permission_handler/permission_handler.dart'; // Added for permissions
import 'package:path_provider/path_provider.dart'; // Added for saving image
import 'package:behaviormind/providers/settings_provider.dart'; // Added for settings

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
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

  // Adapted from EditProfileScreen
  ImageProvider _determineBackgroundImage(String? imagePath, UserProvider userProvider) {
    final currentUser = userProvider.user;

    // Check current imagePath (passed directly, likely from user.profileImage of the current build context)
    if (imagePath != null && imagePath.isNotEmpty) {
      if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
        return NetworkImage(imagePath);
      } else if (path.isAbsolute(imagePath)) {
        return FileImage(File(imagePath));
      } else if (imagePath == 'assets/images/profile_default.png') { // Explicitly handle default asset
        return const AssetImage('assets/images/profile_default.png');
      }
      // If it's not http, not absolute, and not the default asset string,
      // it might be an asset string that's not the default, or an invalid path.
      // Try AssetImage for any other non-empty, non-http, non-absolute path.
      // This assumes other asset paths are possible. If not, this could be stricter.
      return AssetImage(imagePath);
    }

    // Fallback to user data from provider if imagePath is null or empty
    if (currentUser != null && currentUser.profileImage.isNotEmpty) {
      final userProfileImage = currentUser.profileImage;
      if (userProfileImage.startsWith('http') || userProfileImage.startsWith('https')) {
        return NetworkImage(userProfileImage);
      } else if (path.isAbsolute(userProfileImage)) {
        return FileImage(File(userProfileImage));
      }
      // Similar to above, attempt AssetImage for other cases
      return AssetImage(userProfileImage);
    }
    
    // Final fallback to default asset
    return const AssetImage('assets/images/profile_default.png');
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
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
                            backgroundColor: AppColors.primary.withAlpha((0.2 * 255).round()),
                            backgroundImage: _determineBackgroundImage(user.profileImage, userProvider),
                            child: user.profileImage.isEmpty || user.profileImage == 'assets/images/profile_default.png'
                                ? const Icon(Icons.person, size: 50, color: AppColors.primary) 
                                : null,
                          ),
                          GestureDetector(
                            onTap: () {
                              _showChangeProfilePhotoDialog(context, userProvider);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
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
                                icon: const Icon(Icons.edit_outlined),
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
                                icon: const Icon(Icons.edit_outlined),
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
                                icon: const Icon(Icons.add_circle_outline),
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
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout_outlined,
                            color: Colors.red,
                          ),
                          SizedBox(width: 12),
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
            color: color.withAlpha((0.1 * 255).round()),
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
          const Text(
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
          final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
          if (settingsProvider.inAppAlerts) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Profile updated successfully'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
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
          final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
          if (settingsProvider.inAppAlerts) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Health goals updated successfully'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
      ),
    );
  }
  
  Future<void> _handleImageSelection(BuildContext context, UserProvider userProvider, ImageSource source) async {
    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else { // Gallery
      if (Platform.isAndroid) {
        // Try Permission.photos (for API 33+ primarily, maps to READ_MEDIA_IMAGES)
        PermissionStatus photosStatus = await Permission.photos.request();
        if (photosStatus.isGranted) {
          status = photosStatus;
        } else {
          // If Permission.photos is not granted (e.g., user denied on API 33+,
          // or on older Android where it might be .permanentlyDenied without prompt as it's not applicable),
          // then try Permission.storage as a fallback.
          status = await Permission.storage.request(); // For older Android or if .photos failed
        }
      } else { // iOS
        status = await Permission.photos.request();
      }
    }

    if (status.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        try {
          final directory = await getApplicationDocumentsDirectory();
          final fileName = path.basename(pickedFile.path);
          final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
          final savedImage = await File(pickedFile.path).copy('${directory.path}/$uniqueFileName');
          
          userProvider.updateProfileImage(savedImage.path);

          if (context.mounted) {
            final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
            if (settingsProvider.inAppAlerts) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Profile photo updated successfully'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          }
        } catch (e) {
          if (context.mounted) {
            final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
            if (settingsProvider.inAppAlerts) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to save image: ${e.toString()}')),
              );
            }
          }
        }
      } else {
        // User cancelled the picker
        if (context.mounted) {
          final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
          if (settingsProvider.inAppAlerts) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image selection cancelled.')),
            );
          }
        }
      }
    } else {
      // Permission denied
      if (context.mounted) {
        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
        if (settingsProvider.inAppAlerts) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${source == ImageSource.camera ? "Camera" : "Gallery"} permission denied.')),
          );
        }
        // openAppSettings();
      }
    }
  }

  void _showChangeProfilePhotoDialog(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Change Profile Photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _handleImageSelection(context, userProvider, ImageSource.gallery);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _handleImageSelection(context, userProvider, ImageSource.camera);
                },
              ),
              if (userProvider.user!.profileImage.isNotEmpty && userProvider.user!.profileImage != 'assets/images/profile_default.png')
                Column(
                  children: [
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: const Text('Remove Current Photo'),
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
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
  
  void _removeProfilePhoto(BuildContext context, UserProvider userProvider) {
    userProvider.updateProfileImage('');
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    if (settingsProvider.inAppAlerts) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile photo removed'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}