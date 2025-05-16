import 'package:flutter/material.dart';
import 'package:behaviormind/theme/colors.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Settings state
  bool _inAppAlerts = false;
  bool _dailyInsights = true;
  bool _lowActivityAlerts = true;
  bool _sleepGoalReminders = true;
  bool _predictionUpdates = true;
  bool _weeklyProgress = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Manage your notification preferences.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14.0,
                ),
              ),
            ),
            _buildNotificationSetting(
              icon: Icons.notifications,
              title: 'In-App Alerts',
              subtitle: 'Show general status messages and confirmations within the app.',
              value: _inAppAlerts,
              onChanged: (value) {
                setState(() {
                  _inAppAlerts = value;
                });
              },
            ),
            _buildDivider(),
            _buildNotificationSetting(
              icon: Icons.lightbulb_outline,
              title: 'Daily Insights',
              subtitle: 'Receive daily summaries and insights.',
              value: _dailyInsights,
              onChanged: (value) {
                setState(() {
                  _dailyInsights = value;
                });
              },
            ),
            _buildDivider(),
            _buildNotificationSetting(
              icon: Icons.trending_down,
              title: 'Low Activity Alerts',
              subtitle: 'Get notified if your activity is lower than usual.',
              value: _lowActivityAlerts,
              onChanged: (value) {
                setState(() {
                  _lowActivityAlerts = value;
                });
              },
            ),
            _buildDivider(),
            _buildNotificationSetting(
              icon: Icons.nightlight_round,
              title: 'Sleep Goal Reminders',
              subtitle: 'Reminders to help you meet your sleep goals.',
              value: _sleepGoalReminders,
              onChanged: (value) {
                setState(() {
                  _sleepGoalReminders = value;
                });
              },
            ),
            _buildDivider(),
            _buildNotificationSetting(
              icon: Icons.timeline,
              title: 'Prediction Updates',
              subtitle: 'Notifications when new behavior predictions are ready.',
              value: _predictionUpdates,
              onChanged: (value) {
                setState(() {
                  _predictionUpdates = value;
                });
              },
            ),
            _buildDivider(),
            _buildNotificationSetting(
              icon: Icons.event_note,
              title: 'Weekly Progress',
              subtitle: 'A summary of your weekly achievements.',
              value: _weeklyProgress,
              onChanged: (value) {
                setState(() {
                  _weeklyProgress = value;
                });
              },
            ),
            _buildDivider(),
            SizedBox(height: 100.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50.0,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Done'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSetting({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 24.0,
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1.0,
      indent: 56.0,
    );
  }
}
