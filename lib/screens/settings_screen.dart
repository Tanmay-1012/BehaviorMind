import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:behaviormind/providers/settings_provider.dart';
import 'package:behaviormind/theme/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance section
            _buildSectionHeader(context, 'Appearance'),
            _buildToggleSetting(
              context,
              'Dark Mode',
              'Switch between light and dark theme',
              settingsProvider.isDarkMode,
              (value) => settingsProvider.setDarkMode(value),
              Icons.dark_mode_outlined,
            ),
            _buildDropdownSetting(
              context,
              'Language',
              'Select your preferred language',
              settingsProvider.language,
              ['English', 'Spanish', 'French', 'German'],
              (value) => settingsProvider.setLanguage(value),
              Icons.language_outlined,
            ),
            
            // Data section
            _buildSectionHeader(context, 'Data'),
            _buildToggleSetting(
              context,
              'Auto Data Sync',
              'Automatically sync data with connected devices',
              settingsProvider.autoDataSync,
              (value) => settingsProvider.setAutoDataSync(value),
              Icons.sync_outlined,
            ),
            _buildDeviceConnectionItem(
              context,
              'Google Fit',
              settingsProvider.googleFitConnected,
              (value) => settingsProvider.setGoogleFitConnected(value),
              Icons.fitness_center_outlined,
            ),
            _buildDeviceConnectionItem(
              context,
              'Samsung Health',
              settingsProvider.samsungHealthConnected,
              (value) => settingsProvider.setSamsungHealthConnected(value),
              Icons.monitor_heart_outlined,
            ),
            
            // Permission section
            _buildSectionHeader(context, 'Permissions'),
            _buildPermissionSetting(
              context,
              'Location Access',
              'Allow the app to access your location',
              settingsProvider.locationAccess,
              ['Allow', 'Deny'],
              (value) => settingsProvider.setLocationAccess(value),
              Icons.location_on_outlined,
            ),
            _buildPermissionSetting(
              context,
              'Browser Notifications',
              'Allow the app to send browser notifications',
              settingsProvider.browserNotifications,
              ['Allow', 'Deny'],
              (value) => settingsProvider.setBrowserNotifications(value),
              Icons.notifications_outlined,
            ),
            _buildPermissionSetting(
              context,
              'Camera Access',
              'Allow the app to access the camera',
              settingsProvider.cameraAccess,
              ['Allow', 'Deny'],
              (value) => settingsProvider.setCameraAccess(value),
              Icons.camera_alt_outlined,
            ),
            
            // Notifications section
            _buildSectionHeader(context, 'Notifications'),
            _buildToggleSetting(
              context,
              'In-App Alerts',
              'Show alerts within the app',
              settingsProvider.inAppAlerts,
              (value) => settingsProvider.setInAppAlerts(value),
              Icons.notifications_active_outlined,
            ),
            _buildToggleSetting(
              context,
              'Daily Insights',
              'Receive daily insights about your activities',
              settingsProvider.dailyInsights,
              (value) => settingsProvider.setDailyInsights(value),
              Icons.insights_outlined,
            ),
            _buildToggleSetting(
              context,
              'Low Activity Alerts',
              'Notify when activity is below your goal',
              settingsProvider.lowActivityAlerts,
              (value) => settingsProvider.setLowActivityAlerts(value),
              Icons.directions_walk_outlined,
            ),
            _buildToggleSetting(
              context,
              'Sleep Goal Reminders',
              'Reminders to prepare for sleep',
              settingsProvider.sleepGoalReminders,
              (value) => settingsProvider.setSleepGoalReminders(value),
              Icons.nightlight_outlined,
            ),
            _buildToggleSetting(
              context,
              'Prediction Updates',
              'Notify when new predictions are available',
              settingsProvider.predictionUpdates,
              (value) => settingsProvider.setPredictionUpdates(value),
              Icons.update_outlined,
            ),
            _buildToggleSetting(
              context,
              'Weekly Progress',
              'Receive weekly progress summaries',
              settingsProvider.weeklyProgress,
              (value) => settingsProvider.setWeeklyProgress(value),
              Icons.bar_chart_outlined,
            ),
            
            // Reset button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  _showResetConfirmation(context, settingsProvider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Reset All Settings'),
              ),
            ),
            
            // App information
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'BehaviorMind',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '© 2025 BehaviorMind Team',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildToggleSetting(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
  
  Widget _buildDropdownSetting(
    BuildContext context,
    String title,
    String subtitle,
    String currentValue,
    List<String> options,
    Function(String) onChanged,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: currentValue,
        underline: SizedBox(),
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
        items: options.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildDeviceConnectionItem(
    BuildContext context,
    String title,
    bool isConnected,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(isConnected ? 'Connected' : 'Not connected'),
      trailing: Switch(
        value: isConnected,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }
  
  Widget _buildPermissionSetting(
    BuildContext context,
    String title,
    String subtitle,
    String currentValue,
    List<String> options,
    Function(String) onChanged,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: currentValue == 'Allow' ? AppColors.success.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        ),
        child: DropdownButton<String>(
          value: currentValue,
          underline: SizedBox(),
          icon: Icon(
            Icons.arrow_drop_down,
            color: currentValue == 'Allow' ? AppColors.success : Colors.grey,
          ),
          dropdownColor: Theme.of(context).cardColor,
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  option,
                  style: TextStyle(
                    color: option == 'Allow' ? AppColors.success : Colors.grey,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
  
  void _showResetConfirmation(BuildContext context, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Reset Settings'),
          content: Text('Are you sure you want to reset all settings to their default values?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                settingsProvider.resetToDefaults();
                Navigator.of(dialogContext).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('All settings have been reset to defaults'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: Text('Reset'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }
}