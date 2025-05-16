import 'package:flutter/material.dart';
import 'package:behaviormind/models/activity_model.dart';
import 'package:behaviormind/theme/colors.dart';
import 'package:behaviormind/utils/date_formatter.dart';
import 'package:behaviormind/widgets/activity_detail_modal.dart';
import 'package:fl_chart/fl_chart.dart';

class HistoricalActivityList extends StatefulWidget {
  final List<DailyActivity> activities;
  
  const HistoricalActivityList({
    Key? key,
    required this.activities,
  }) : super(key: key);

  @override
  _HistoricalActivityListState createState() => _HistoricalActivityListState();
}

class _HistoricalActivityListState extends State<HistoricalActivityList> {
  @override
  Widget build(BuildContext context) {
    // Sort activities by date, newest first
    final sortedActivities = List<DailyActivity>.from(widget.activities);
    sortedActivities.sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));
    
    // Limit to 15 days
    final activities = sortedActivities.take(15).toList();
    
    if (activities.isEmpty) {
      return Center(
        child: Text('No historical activity data available'),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        final date = DateTime.parse(activity.date);
        final isToday = DateTime.now().difference(date).inDays == 0;
        
        // Determine mood color
        Color moodColor;
        switch (activity.mood) {
          case MoodType.positive:
            moodColor = AppColors.moodPositive;
            break;
          case MoodType.negative:
            moodColor = AppColors.moodNegative;
            break;
          case MoodType.mixed:
            moodColor = AppColors.moodMixed;
            break;
          default:
            moodColor = AppColors.moodNeutral;
        }
        
        return Card(
          margin: EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isToday ? BorderSide(color: AppColors.primary, width: 2) : BorderSide.none,
          ),
          child: InkWell(
            onTap: () => _showActivityDetails(context, activity),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            DateFormatter.getRelativeDateString(date),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isToday) 
                            Container(
                              margin: EdgeInsets.only(left: 8),
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Today',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: moodColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              activity.mood.icon,
                              color: moodColor,
                              size: 16,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            activity.mood.displayName.split(' ')[0], // Just the mood name
                            style: TextStyle(
                              color: moodColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      _buildActivityMetric(
                        context, 
                        Icons.directions_walk, 
                        '${activity.steps}', 
                        'Steps',
                        AppColors.primary,
                      ),
                      _buildActivityMetric(
                        context, 
                        Icons.phone_android, 
                        '${activity.screenTimeHours}h', 
                        'Screen',
                        AppColors.secondary,
                      ),
                      _buildActivityMetric(
                        context, 
                        Icons.tips_and_updates_outlined, 
                        '${activity.suggestions.length}', 
                        'Tips',
                        AppColors.accent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildActivityMetric(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _showActivityDetails(BuildContext context, DailyActivity activity) {
    // Convert activity data to chart spots
    final stepsData = List.generate(12, (i) => 
      FlSpot(i.toDouble(), 200 + ((activity.steps / 24) * (i % 12))));
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: ActivityDetailModal(
              title: 'Daily Activity',
              value: activity.steps.toString(),
              unit: 'steps',
              icon: Icons.directions_walk,
              color: AppColors.primary,
              progress: activity.steps.toDouble(),
              goal: 10000,
              goalUnit: 'steps',
              chartData: stepsData,
              extraData: {
                'date': activity.date,
                'screenTime': activity.screenTimeHours,
                'mood': activity.mood.toString(),
                'suggestions': activity.suggestions,
              },
            ),
          );
        },
      ),
    );
  }
}