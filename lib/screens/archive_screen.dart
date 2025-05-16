import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:behaviormind/providers/health_data_provider.dart';
import 'package:behaviormind/routes.dart';
import 'package:behaviormind/theme/colors.dart';
import 'package:behaviormind/models/health_data_model.dart';
import 'package:behaviormind/models/activity_model.dart';
import 'package:behaviormind/utils/date_formatter.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({Key? key}) : super(key: key);

  @override
  _ArchiveScreenState createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  int _selectedIndex = 2;
  DateTime _selectedDate = DateTime.now();
  
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
        // Already on archive screen
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final healthProvider = Provider.of<HealthDataProvider>(context);
    final activityData = healthProvider.activityData;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Archive'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today_outlined),
            onPressed: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              
              if (pickedDate != null) {
                setState(() {
                  _selectedDate = pickedDate;
                });
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
        ],
      ),
      body: activityData.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No activity data available',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start tracking your activities to see them here',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calendar view (simplified)
                  _buildCalendarStrip(context, activityData),
                  
                  const SizedBox(height: 24),
                  
                  // Daily activity breakdown
                  _buildDailyActivityCard(context, activityData),
                  
                  const SizedBox(height: 16),
                  
                  // Activity details
                  _buildActivityDetailsCard(context, healthProvider),
                  
                  const SizedBox(height: 16),
                  
                  // Mood tracking
                  _buildMoodTrackingCard(context, activityData),
                  
                  const SizedBox(height: 16),
                  
                  // Daily suggestions
                  _buildSuggestionsCard(context, activityData),
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
  
  Widget _buildCalendarStrip(BuildContext context, List<DailyActivity> activityData) {
    // Get unique dates from activity data, sorted newest to oldest
    final dates = activityData.map((activity) => DateTime.parse(activity.date)).toList();
    dates.sort((a, b) => b.compareTo(a)); // Sort descending
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity History',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Container(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final isSelected = date.year == _selectedDate.year && 
                                date.month == _selectedDate.month && 
                                date.day == _selectedDate.day;
              
              // Find corresponding activity
              final activity = activityData.firstWhere(
                (a) => a.date == DateFormatter.formatIso(date),
                orElse: () => DailyActivity.demo(DateFormatter.formatIso(date)),
              );
              
              // Determine color based on mood
              Color moodColor;
              switch (activity.mood) {
                case MoodType.positive:
                  moodColor = AppColors.moodPositive;
                  break;
                case MoodType.neutral:
                  moodColor = AppColors.moodNeutral;
                  break;
                case MoodType.negative:
                  moodColor = AppColors.moodNegative;
                  break;
                case MoodType.mixed:
                  moodColor = AppColors.moodMixed;
                  break;
              }
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: Container(
                  width: 70,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                    border: Border.all(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormatter.formatDayOfWeek(date),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Theme.of(context).primaryColor : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Theme.of(context).primaryColor : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: moodColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildDailyActivityCard(BuildContext context, List<DailyActivity> activityData) {
    // Find activity for selected date
    final selectedDateStr = DateFormatter.formatIso(_selectedDate);
    final activity = activityData.firstWhere(
      (a) => a.date == selectedDateStr,
      orElse: () => DailyActivity.demo(selectedDateStr),
    );
    
    String moodText;
    Color moodColor;
    
    switch (activity.mood) {
      case MoodType.positive:
        moodText = 'Positive';
        moodColor = AppColors.moodPositive;
        break;
      case MoodType.neutral:
        moodText = 'Neutral';
        moodColor = AppColors.moodNeutral;
        break;
      case MoodType.negative:
        moodText = 'Negative';
        moodColor = AppColors.moodNegative;
        break;
      case MoodType.mixed:
        moodText = 'Mixed';
        moodColor = AppColors.moodMixed;
        break;
    }
    
    return Card(
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
                  DateFormatter.formatFullDate(_selectedDate),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: moodColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: moodColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        moodText,
                        style: TextStyle(
                          color: moodColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActivityStat(
                  context,
                  'Steps',
                  activity.steps.toString(),
                  Icons.directions_walk,
                  AppColors.primary,
                ),
                _buildActivityStat(
                  context,
                  'Screen Time',
                  '${activity.screenTimeHours.toStringAsFixed(1)} hrs',
                  Icons.phone_android,
                  AppColors.secondary,
                ),
                _buildActivityStat(
                  context,
                  'Prediction',
                  activity.prediction['type'] ?? 'N/A',
                  Icons.show_chart,
                  AppColors.accent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActivityStat(
    BuildContext context, 
    String title, 
    String value, 
    IconData icon, 
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
  
  Widget _buildActivityDetailsCard(BuildContext context, HealthDataProvider healthProvider) {
    // Find health data for selected date
    final selectedDateStr = DateFormatter.formatIso(_selectedDate);
    final healthData = healthProvider.healthData.firstWhere(
      (data) => data.date == selectedDateStr,
      orElse: () => HealthData.demoForDate(selectedDateStr),
    );
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health Data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Sleep data
            _buildDetailRow(
              context,
              'Sleep Duration',
              '${healthData.sleep.totalHours.toStringAsFixed(1)} hours',
              Icons.nightlight_round,
              AppColors.secondary,
            ),
            const SizedBox(height: 12),
            _buildSleepBreakdown(context, healthData.sleep),
            const SizedBox(height: 16),
            
            // Activity data
            _buildDetailRow(
              context,
              'Steps',
              healthData.steps.toString(),
              Icons.directions_walk,
              AppColors.primary,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              'Distance Walked',
              '${healthData.distanceWalked.toStringAsFixed(1)} km',
              Icons.straighten,
              AppColors.primary,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              'Active Minutes',
              '${healthData.activeMinutes} min',
              Icons.timer,
              AppColors.primary,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              'Calories Burned',
              '${healthData.caloriesBurned} kcal',
              Icons.local_fire_department,
              AppColors.error,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              'Avg. Heart Rate',
              '${healthData.heartRate} bpm',
              Icons.favorite,
              AppColors.error,
            ),
            
            // Workouts section
            if (healthData.workouts.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Workouts',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ...healthData.workouts.map((workout) => _buildWorkoutItem(context, workout)),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 12),
        Text(
          title,
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
  
  Widget _buildSleepBreakdown(BuildContext context, SleepData sleep) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sleep Breakdown:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: 1.0,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  sleep.deepSleepHours / sleep.totalHours > 0.25 ? 
                    AppColors.success : AppColors.warning
                ),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${(sleep.deepSleepHours / sleep.totalHours * 100).toInt()}% deep',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Deep: ${sleep.deepSleepHours.toStringAsFixed(1)}h • Light: ${sleep.lightSleepHours.toStringAsFixed(1)}h • REM: ${sleep.remSleepHours.toStringAsFixed(1)}h • Awake: ${sleep.awakeSleepHours.toStringAsFixed(1)}h',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
  
  Widget _buildWorkoutItem(BuildContext context, WorkoutData workout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            _getWorkoutIcon(workout.type),
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.type,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${workout.startTime} - ${workout.endTime}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${workout.durationMinutes} min',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${workout.caloriesBurned} kcal',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  IconData _getWorkoutIcon(String workoutType) {
    switch (workoutType.toLowerCase()) {
      case 'running':
        return Icons.directions_run;
      case 'walking':
        return Icons.directions_walk;
      case 'cycling':
        return Icons.directions_bike;
      case 'strength training':
        return Icons.fitness_center;
      case 'yoga':
        return Icons.self_improvement;
      case 'swimming':
        return Icons.pool;
      case 'hiit':
        return Icons.timer;
      default:
        return Icons.sports;
    }
  }
  
  Widget _buildMoodTrackingCard(BuildContext context, List<DailyActivity> activityData) {
    // Find activity for selected date
    final selectedDateStr = DateFormatter.formatIso(_selectedDate);
    final activity = activityData.firstWhere(
      (a) => a.date == selectedDateStr,
      orElse: () => DailyActivity.demo(selectedDateStr),
    );
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mood & Behavior',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Display the prediction message
            if (activity.prediction.containsKey('message'))
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        activity.prediction['message'],
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              
            const SizedBox(height: 16),
            
            // Mood options (just display, not interactive in this demo)
            Text(
              'Mood Tracking',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMoodOption(context, 'Positive', AppColors.moodPositive, activity.mood == MoodType.positive),
                _buildMoodOption(context, 'Neutral', AppColors.moodNeutral, activity.mood == MoodType.neutral),
                _buildMoodOption(context, 'Negative', AppColors.moodNegative, activity.mood == MoodType.negative),
                _buildMoodOption(context, 'Mixed', AppColors.moodMixed, activity.mood == MoodType.mixed),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMoodOption(BuildContext context, String label, Color color, bool isSelected) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: isSelected ? Border.all(color: color, width: 2) : null,
          ),
          child: isSelected 
              ? Icon(Icons.check, color: Colors.white) 
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSuggestionsCard(BuildContext context, List<DailyActivity> activityData) {
    // Find activity for selected date
    final selectedDateStr = DateFormatter.formatIso(_selectedDate);
    final activity = activityData.firstWhere(
      (a) => a.date == selectedDateStr,
      orElse: () => DailyActivity.demo(selectedDateStr),
    );
    
    if (activity.suggestions.isEmpty) {
      return SizedBox.shrink();
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Suggestions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            ...activity.suggestions.map((suggestion) {
              final isFollowed = activity.suggestionsFollowed[suggestion] ?? false;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isFollowed 
                      ? AppColors.success.withOpacity(0.1) 
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isFollowed 
                        ? AppColors.success 
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isFollowed 
                            ? AppColors.success 
                            : Colors.grey.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFollowed ? Icons.check : Icons.add,
                        color: isFollowed ? Colors.white : Colors.grey,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          decoration: isFollowed ? TextDecoration.lineThrough : null,
                          color: isFollowed ? Colors.grey : null,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}