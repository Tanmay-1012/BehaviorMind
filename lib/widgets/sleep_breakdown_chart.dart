import 'package:flutter/material.dart';
import 'package:behaviormind/models/health_data_model.dart';
import 'package:behaviormind/theme/colors.dart';
import 'package:fl_chart/fl_chart.dart';

class SleepBreakdownChart extends StatelessWidget {
  final SleepData sleepData;
  final double height;
  
  const SleepBreakdownChart({
    Key? key,
    required this.sleepData,
    this.height = 250,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sleep quality indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${sleepData.totalHours.toStringAsFixed(1)} hours',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildSleepQualityBadge(context),
            ],
          ),
          SizedBox(height: 20),
          
          // Sleep phases visualization
          Container(
            height: 60,
            child: _buildSleepPhasesTimeline(context),
          ),
          
          SizedBox(height: 20),
          
          // Sleep phases legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSleepPhaseLegendItem(
                context, 
                'Deep', 
                Colors.indigo, 
                '${sleepData.deepSleepHours.toStringAsFixed(1)}h',
                '${(sleepData.deepSleepHours / sleepData.totalHours * 100).round()}%',
              ),
              _buildSleepPhaseLegendItem(
                context, 
                'Light', 
                Colors.blue.shade300, 
                '${sleepData.lightSleepHours.toStringAsFixed(1)}h',
                '${(sleepData.lightSleepHours / sleepData.totalHours * 100).round()}%',
              ),
              _buildSleepPhaseLegendItem(
                context, 
                'REM', 
                Colors.purple.shade300, 
                '${sleepData.remSleepHours.toStringAsFixed(1)}h',
                '${(sleepData.remSleepHours / sleepData.totalHours * 100).round()}%',
              ),
              _buildSleepPhaseLegendItem(
                context, 
                'Awake', 
                Colors.grey.shade400, 
                '${sleepData.awakeSleepHours.toStringAsFixed(1)}h',
                '${(sleepData.awakeSleepHours / sleepData.totalHours * 100).round()}%',
              ),
            ],
          ),
          
          SizedBox(height: 20),
          
          // Hours per day line chart
          Expanded(
            child: _buildSleepHoursLineChart(context),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSleepQualityBadge(BuildContext context) {
    final Color color = _getSleepQualityColor();
    final String text = _getSleepQualityText();
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getSleepQualityIcon(),
            color: color,
            size: 16,
          ),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getSleepQualityColor() {
    if (sleepData.totalHours >= 7.5) return Colors.green;
    if (sleepData.totalHours >= 6.0) return Colors.orange;
    return Colors.red;
  }
  
  String _getSleepQualityText() {
    if (sleepData.totalHours >= 7.5) return 'Good';
    if (sleepData.totalHours >= 6.0) return 'Fair';
    return 'Poor';
  }
  
  IconData _getSleepQualityIcon() {
    if (sleepData.totalHours >= 7.5) return Icons.thumb_up;
    if (sleepData.totalHours >= 6.0) return Icons.thumbs_up_down;
    return Icons.thumb_down;
  }
  
  Widget _buildSleepPhasesTimeline(BuildContext context) {
    // Calculate percentages for display
    final totalHours = sleepData.totalHours;
    final deepPercent = sleepData.deepSleepHours / totalHours * 100;
    final lightPercent = sleepData.lightSleepHours / totalHours * 100;
    final remPercent = sleepData.remSleepHours / totalHours * 100;
    final awakePercent = sleepData.awakeSleepHours / totalHours * 100;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Expanded(
            flex: deepPercent.round(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            flex: lightPercent.round(),
            child: Container(
              color: Colors.blue.shade300,
            ),
          ),
          Expanded(
            flex: remPercent.round(),
            child: Container(
              color: Colors.purple.shade300,
            ),
          ),
          Expanded(
            flex: awakePercent.round(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSleepPhaseLegendItem(
    BuildContext context,
    String label,
    Color color,
    String hours,
    String percentage,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          hours,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          percentage,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSleepHoursLineChart(BuildContext context) {
    // For demo purposes, we'll create some sample data points
    // In a real app, this would come from historical data
    
    final now = DateTime.now();
    final List<FlSpot> spots = [];
    final List<String> days = [];
    
    // Create 7 days of sample data
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      days.add(_getDayLabel(day));
      
      // Generate a somewhat realistic sleep pattern
      double hours = 0;
      
      if (i == 0) {
        // Today's actual hours
        hours = sleepData.totalHours;
      } else {
        // Past days with some variation
        hours = 7.0 + (day.day % 3) * 0.5 - (day.day % 2) * 0.8;
        hours = double.parse(hours.toStringAsFixed(1));
      }
      
      spots.add(FlSpot((6 - i).toDouble(), hours));
    }
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final int index = value.toInt();
                if (index >= 0 && index < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      days[index],
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    '${value.toInt()}h',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        minY: 4, // Minimum 4 hours
        maxY: 10, // Maximum 10 hours
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: _getSleepQualityColor(),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final isToday = index == spots.length - 1;
                
                return FlDotCirclePainter(
                  radius: isToday ? 6 : 4,
                  color: isToday ? _getSleepQualityColor() : _getSleepQualityColor().withOpacity(0.7),
                  strokeWidth: isToday ? 2 : 0,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: _getSleepQualityColor().withOpacity(0.2),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.black.withOpacity(0.8),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)} hours',
                  TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
  
  String _getDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final dateDay = DateTime(date.year, date.month, date.day);
    
    if (dateDay == today) {
      return 'Today';
    } else if (dateDay == yesterday) {
      return 'Yst';
    } else {
      final weekday = _getShortWeekdayName(date.weekday);
      return weekday;
    }
  }
  
  String _getShortWeekdayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }
}