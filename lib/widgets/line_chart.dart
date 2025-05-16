import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:behaviormind/theme/colors.dart';

class StepLineChart extends StatelessWidget {
  final List<FlSpot> actual;
  final List<FlSpot> predicted;

  const StepLineChart({
    Key? key,
    required this.actual,
    required this.predicted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.black.withOpacity(0.8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final type = barSpot.barIndex == 0 ? 'Actual' : 'Predicted';
                return LineTooltipItem(
                  '$type: ${barSpot.y.toInt()}',
                  TextStyle(
                    color: barSpot.barIndex == 0 ? AppColors.primary : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: false,
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                if (value >= 0 && value < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      days[value.toInt()],
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const steps = [5000, 6000, 7000, 8000, 9000];
                if (steps.contains(value.toInt())) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      '${value.toInt()}',
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
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        minX: 0,
        maxX: 6,
        minY: 5000,
        maxY: 9000,
        lineBarsData: [
          LineChartBarData(
            spots: actual,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(show: false),
          ),
          LineChartBarData(
            spots: predicted,
            isCurved: true,
            color: Colors.orange,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.orange,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(show: false),
            dashArray: [5, 5],
          ),
        ],
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 7000,
              color: Colors.white.withOpacity(0.2),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ],
        ),
      ),
    );
  }
}
