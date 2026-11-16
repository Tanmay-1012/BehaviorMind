import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:behaviormind/theme/colors.dart';

class ActivityDetailModal extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final double progress;
  final double goal;
  final String goalUnit;
  final List<FlSpot> chartData;
  final Map<String, dynamic>? extraData;

  const ActivityDetailModal({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.progress,
    required this.goal,
    required this.goalUnit,
    required this.chartData,
    this.extraData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon, title and close button
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withAlpha((0.2 * 255).round()),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Text(
                  '$title Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: color),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Current value
            Text(
              '$title ($unit)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '$value $unit',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Progress bar
            Row(
              children: [
                Text(
                  'Daily Goal',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                Text(
                  '$progress / $goal $goalUnit',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress / goal,
              backgroundColor: Colors.grey.withAlpha((0.2 * 255).round()),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 24),

            // Activity chart
            Text(
              'Activity Over Time',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withAlpha((0.2 * 255).round()),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          // Show hours or similar
                          final labels = [
                            '12AM',
                            '2AM',
                            '4AM',
                            '6AM',
                            '8AM',
                            '10AM',
                            '12PM',
                            '2PM',
                            '4PM',
                            '6PM',
                            '8PM',
                            '11PM'
                          ];
                          final index = value.toInt();
                          if (index >= 0 && index < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                labels[index],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (LineBarSpot spot) => Colors.black.withAlpha((0.7 * 255).round()),
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((touchedSpot) {
                          // final flSpot = touchedSpot; // Not strictly needed if using touchedSpot directly
                          return LineTooltipItem(
                            '${touchedSpot.y.toStringAsFixed(1)} $unit',
                            const TextStyle(
                              color: Colors.white, 
                              fontSize: 12, // Adjusted to match my earlier intention
                              fontWeight: FontWeight.bold),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData,
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: color,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withAlpha((0.2 * 255).round()),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Extra data if available
            if (extraData != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              
              // Screen time breakdown
              if (title == 'Daily Activity' || title == 'Screen Time')
                _buildScreenTimeBreakdown(context),
                
              // Activity summary and insights
              if (title == 'Daily Activity')
                _buildActivitySummary(context),
                
              // Suggestions
              if (extraData!.containsKey('suggestions') && 
                  (extraData!['suggestions'] as List).isNotEmpty)
                _buildSuggestions(context),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildScreenTimeBreakdown(BuildContext context) {
    final appUsage = [
      {'name': 'Social', 'time': '1h 40m', 'color': AppColors.primary},
      {'name': 'Productivity', 'time': '1h 25m', 'color': Colors.orange},
      {'name': 'Games', 'time': '55m', 'color': AppColors.accent},
      {'name': 'Entertainment', 'time': '43m', 'color': Colors.pinkAccent},
      {'name': 'Finance', 'time': '25m', 'color': Colors.blueGrey},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'App Usage Breakdown',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        ...appUsage.map((app) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: app['color'] as Color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        app['name'] as String,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Text(
                        app['time'] as String,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: _getProgressValue(app['time'] as String),
                    backgroundColor: Colors.grey.withAlpha((0.2 * 255).round()),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(app['color'] as Color),
                    minHeight: 4,
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildActivitySummary(BuildContext context) {
    // Determine mood type and message
    String moodMessage = 'Your mood was neutral today.';
    Color moodColor = Colors.grey;
    
    if (extraData!.containsKey('mood')) {
      final mood = extraData!['mood'] as String;
      if (mood.contains('positive')) {
        moodMessage = 'You had a positive day! Your general mood was good.';
        moodColor = AppColors.moodPositive;
      } else if (mood.contains('negative')) {
        moodMessage = 'You had a challenging day. Your general mood was low.';
        moodColor = AppColors.moodNegative;
      } else if (mood.contains('mixed')) {
        moodMessage = 'You had a mixed day with both highs and lows.';
        moodColor = AppColors.moodMixed;
      }
    }
    
    // Activity progress assessment
    final stepProgress = progress / goal;
    String activityMessage;
    if (stepProgress >= 1.0) {
      activityMessage = 'Great job! You reached your daily step goal.';
    } else if (stepProgress >= 0.8) {
      activityMessage = 'Almost there! You made good progress toward your step goal.';
    } else if (stepProgress >= 0.5) {
      activityMessage = 'You made decent progress on your step goal today.';
    } else {
      activityMessage = 'You were less active than usual today.';
    }
    
    // Screen time assessment
    double screenHours = 0;
    if (extraData!.containsKey('screenTime')) {
      screenHours = extraData!['screenTime'] as double;
    }
    
    String screenMessage;
    if (screenHours > 5) {
      screenMessage = 'Your screen time was quite high today. Consider taking more breaks.';
    } else if (screenHours > 3) {
      screenMessage = 'Your screen time was moderate today.';
    } else {
      screenMessage = 'Your screen time was lower than average today. Good job!';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Summary',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        _buildSummaryItem(
          context,
          Icons.sentiment_satisfied_alt,
          'Mood',
          moodMessage,
          moodColor,
        ),
        const SizedBox(height: 12),
        _buildSummaryItem(
          context,
          Icons.directions_walk,
          'Activity',
          activityMessage,
          AppColors.primary,
        ),
        const SizedBox(height: 12),
        _buildSummaryItem(
          context,
          Icons.phone_android,
          'Screen Time',
          screenMessage,
          AppColors.secondary,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
  
  Widget _buildSummaryItem(
    BuildContext context,
    IconData icon,
    String label,
    String message,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildSuggestions(BuildContext context) {
    List<dynamic> suggestions = extraData!['suggestions'] as List;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Personalized Tips',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        ...suggestions.map((suggestion) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildSuggestionItem(context, suggestion.toString()),
        )),
      ],
    );
  }
  
  Widget _buildSuggestionItem(BuildContext context, String suggestion) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.accent.withAlpha((0.1 * 255).round()),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.tips_and_updates,
            color: AppColors.accent,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            suggestion,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
  
  double _getProgressValue(String time) {
    // Convert time like "1h 40m" to minutes
    double totalMinutes = 0;
    final parts = time.split(' ');
    if (parts.length >= 2) {
      if (parts[0].contains('h')) {
        totalMinutes += double.parse(parts[0].replaceAll('h', '')) * 60;
      }
      if (parts.length > 1 && parts[1].contains('m')) {
        totalMinutes += double.parse(parts[1].replaceAll('m', ''));
      }
    }
    // Return a value between 0 and 1
    return totalMinutes / 329; // Using 5h 29m = 329 minutes as the max
  }
}