import 'package:flutter/material.dart';
import 'package:behaviormind/models/health_data_model.dart';
import 'package:behaviormind/theme/colors.dart';
import 'package:behaviormind/utils/date_formatter.dart';
import 'package:behaviormind/widgets/sleep_breakdown_chart.dart';

class SleepDetailsScreen extends StatelessWidget {
  final SleepData sleepData;
  final String date;

  const SleepDetailsScreen({
    Key? key, 
    required this.sleepData, 
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sleep Analysis'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // Share functionality would be implemented here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sharing sleep data...'))
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date display
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    DateFormatter.formatReadable(DateTime.parse(date)),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Sleep overview
            Row(
              children: [
                Icon(Icons.nightlight_round, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Sleep Overview',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Sleep breakdown chart
            SleepBreakdownChart(
              sleepData: sleepData,
              height: 350,
            ),
            
            SizedBox(height: 24),
            
            // Sleep insights
            _buildInsightsSection(context),
            
            SizedBox(height: 24),
            
            // Sleep tips
            _buildSleepTipsSection(context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInsightsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.insights, color: AppColors.accent),
            SizedBox(width: 8),
            Text(
              'Sleep Insights',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInsightItem(
                  context,
                  'Duration Analysis',
                  _getSleepDurationInsight(),
                  Icons.access_time,
                  Colors.blue,
                ),
                Divider(height: 24),
                _buildInsightItem(
                  context,
                  'Quality Analysis',
                  _getSleepQualityInsight(),
                  Icons.auto_graph,
                  Colors.purple,
                ),
                Divider(height: 24),
                _buildInsightItem(
                  context,
                  'Pattern Analysis',
                  'Your sleep pattern shows consistency in bedtime over the past week, which is beneficial for your circadian rhythm.',
                  Icons.repeat,
                  Colors.green,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildInsightItem(
    BuildContext context,
    String title,
    String message,
    IconData icon,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, size: 16, color: color),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildSleepTipsSection(BuildContext context) {
    final tips = [
      {
        'title': 'Maintain Regular Sleep Hours',
        'description': 'Try to go to bed and wake up at the same time every day, even on weekends.',
        'icon': Icons.schedule,
      },
      {
        'title': 'Create a Relaxing Bedtime Routine',
        'description': 'Establish a pre-sleep routine that helps you unwind, like reading or gentle stretching.',
        'icon': Icons.spa,
      },
      {
        'title': 'Optimize Your Sleep Environment',
        'description': 'Keep your bedroom dark, quiet, and at a comfortable temperature for sleeping.',
        'icon': Icons.bed,
      },
      {
        'title': 'Limit Screen Time Before Bed',
        'description': 'Avoid screens at least 1 hour before bedtime as blue light can disrupt melatonin production.',
        'icon': Icons.phone_android,
      },
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.amber),
            SizedBox(width: 8),
            Text(
              'Sleep Tips',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        SizedBox(height: 16),
        ...tips.map((tip) => _buildTipItem(context, tip)).toList(),
      ],
    );
  }
  
  Widget _buildTipItem(BuildContext context, Map<String, dynamic> tip) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.amber.withOpacity(0.2),
              child: Icon(tip['icon'] as IconData, color: Colors.amber),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip['title'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    tip['description'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
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
  
  String _getSleepDurationInsight() {
    if (sleepData.totalHours >= 7 && sleepData.totalHours <= 9) {
      return 'Your sleep duration of ${sleepData.totalHours.toStringAsFixed(1)} hours falls within the recommended 7-9 hours for adults.';
    } else if (sleepData.totalHours < 7) {
      return 'Your sleep duration of ${sleepData.totalHours.toStringAsFixed(1)} hours is below the recommended 7-9 hours for adults. Consider going to bed earlier.';
    } else {
      return 'Your sleep duration of ${sleepData.totalHours.toStringAsFixed(1)} hours is above the recommended 7-9 hours for adults, which may indicate oversleeping.';
    }
  }
  
  String _getSleepQualityInsight() {
    final deepSleepPercentage = (sleepData.deepSleepHours / sleepData.totalHours) * 100;
    final remSleepPercentage = (sleepData.remSleepHours / sleepData.totalHours) * 100;
    
    if (deepSleepPercentage < 15) {
      return 'Your deep sleep percentage is lower than optimal. Deep sleep is crucial for physical recovery and memory consolidation.';
    } else if (remSleepPercentage < 20) {
      return 'Your REM sleep percentage is lower than optimal. REM sleep is important for cognitive functions and emotional processing.';
    } else if (sleepData.awakeSleepHours > 1) {
      return 'You spent ${sleepData.awakeSleepHours.toStringAsFixed(1)} hours awake during your sleep period, which may indicate sleep disturbances.';
    } else {
      return 'Your sleep cycle shows healthy proportions of deep sleep (${deepSleepPercentage.round()}%) and REM sleep (${remSleepPercentage.round()}%), indicating good quality rest.';
    }
  }
}