import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:behaviormind/theme/colors.dart';

class ChartUtils {
  // Create a list of spots for a line chart with random variations around a base value
  static List<FlSpot> generateRandomSpots(
    int count, 
    double baseValue, 
    double variationPercent,
    {double minY = 0, double? maxY}
  ) {
    final random = Random();
    final spots = <FlSpot>[];
    
    for (int i = 0; i < count; i++) {
      final variation = baseValue * variationPercent * (random.nextDouble() * 2 - 1);
      final value = (baseValue + variation).clamp(minY, maxY ?? double.infinity);
      spots.add(FlSpot(i.toDouble(), value));
    }
    
    return spots;
  }
  
  // Create a list of spots for a line chart from a list of values
  static List<FlSpot> spotsFromValues(List<double> values) {
    final spots = <FlSpot>[];
    
    for (int i = 0; i < values.length; i++) {
      spots.add(FlSpot(i.toDouble(), values[i]));
    }
    
    return spots;
  }
  
  // Generate dates for x-axis labels
  static List<String> generateDateLabels(int days) {
    final now = DateTime.now();
    final labels = <String>[];
    
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: days - i - 1));
      labels.add('${date.month}/${date.day}');
    }
    
    return labels;
  }
  
  // Generate week day labels (Mon, Tue, etc.)
  static List<String> generateWeekdayLabels() {
    return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  }
  
  // Create a gradient for line charts
  static LinearGradient createGradient(Color color, {bool vertical = false}) {
    return LinearGradient(
      colors: [
        color.withOpacity(0.8),
        color.withOpacity(0.0),
      ],
      begin: vertical ? Alignment.topCenter : Alignment.centerLeft,
      end: vertical ? Alignment.bottomCenter : Alignment.centerRight,
    );
  }
  
  // Calculate nice min and max values for Y axis
  static Map<String, double> calculateYAxisBounds(
    List<double> values, 
    {double padding = 0.1}
  ) {
    if (values.isEmpty) {
      return {'min': 0, 'max': 100};
    }
    
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    
    final range = max - min;
    final paddingValue = range * padding;
    
    return {
      'min': (min - paddingValue).clamp(0, double.infinity),
      'max': max + paddingValue,
    };
  }
  
  // Calculate step size for Y axis
  static double calculateYAxisStep(double min, double max, int desiredSteps) {
    final range = max - min;
    final rawStep = range / desiredSteps;
    
    // Round to a nice number
    final magnitude = pow(10, (log(rawStep) / ln10).floor());
    final magnitudeMultiples = [1, 2, 5, 10];
    
    double step = double.infinity;
    for (final multiple in magnitudeMultiples) {
      final candidate = multiple * magnitude;
      if ((range / candidate).round() <= desiredSteps && candidate < step) {
        step = candidate;
      }
    }
    
    return step;
  }
  
  // Create a line chart with title and legend
  static Widget createTitledLineChart({
    required String title,
    required List<LineChartBarData> lines,
    required List<String> legend,
    required List<Color> colors,
    double minY = 0,
    double? maxY,
    List<String>? bottomTitles,
    double height = 200,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Container(
          height: height,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: null,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.white.withOpacity(0.1),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                bottomTitles: bottomTitles != null
                    ? AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value >= 0 && value < bottomTitles.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  bottomTitles[value.toInt()],
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            }
                            return SizedBox();
                          },
                        ),
                      )
                    : AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: null,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: lines.first.spots.length - 1.0,
              minY: minY,
              maxY: maxY,
              lineBarsData: lines,
            ),
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            legend.length,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[index],
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    legend[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Create step line chart dataset
  static LineChartBarData createStepLine({
    required List<FlSpot> spots,
    required Color color,
    bool isDotted = false,
    bool showDots = true,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: showDots,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: color,
            strokeWidth: 1,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(show: false),
      dashArray: isDotted ? [5, 5] : null,
    );
  }
  
  // Calculate chart dimension for a specific dataset
  static ChartDimension calculateChartDimension(List<double> values) {
    if (values.isEmpty) {
      return ChartDimension(min: 0, max: 100, interval: 20);
    }
    
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    
    // Add some padding
    final paddedMin = (min * 0.9).floorToDouble();
    final paddedMax = (max * 1.1).ceilToDouble();
    
    // Calculate a nice interval
    final range = paddedMax - paddedMin;
    final interval = calculateYAxisStep(paddedMin, paddedMax, 5);
    
    return ChartDimension(min: paddedMin, max: paddedMax, interval: interval);
  }
}

// Class to store chart dimensions
class ChartDimension {
  final double min;
  final double max;
  final double interval;
  
  ChartDimension({
    required this.min,
    required this.max,
    required this.interval,
  });
}
