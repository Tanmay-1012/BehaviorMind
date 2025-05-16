import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:behaviormind/models/prediction_model.dart';
import 'package:behaviormind/theme/colors.dart';

class PredictionChart extends StatefulWidget {
  final List<PredictionPoint> points;
  final String title;
  final String description;

  const PredictionChart({
    Key? key,
    required this.points,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  _PredictionChartState createState() => _PredictionChartState();
}

class _PredictionChartState extends State<PredictionChart> with SingleTickerProviderStateMixin {
  bool _showActual = true;
  bool _showPredicted = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDataVisibility(String dataType) {
    _animationController.reset();
    
    setState(() {
      if (dataType == 'actual') {
        _showActual = !_showActual;
      } else if (dataType == 'predicted') {
        _showPredicted = !_showPredicted;
      }
    });
    
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
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
              widget.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  height: 220,
                  child: _buildPredictionChart(_animation.value),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildInteractiveControls(context),
            const SizedBox(height: 16),
            Text(
              widget.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildInteractiveLegendItem(
          context,
          'Actual',
          AppColors.primary,
          _showActual,
          () => _toggleDataVisibility('actual'),
        ),
        const SizedBox(width: 24),
        _buildInteractiveLegendItem(
          context,
          'Predicted',
          AppColors.secondary,
          _showPredicted,
          () => _toggleDataVisibility('predicted'),
        ),
      ],
    );
  }

  Widget _buildInteractiveLegendItem(
    BuildContext context,
    String label,
    Color color,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: isActive ? 1.0 : 0.5,
        duration: Duration(milliseconds: 200),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isActive ? color : color.withOpacity(0.5),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? Colors.white : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isActive 
                    ? Theme.of(context).textTheme.bodySmall?.color 
                    : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionChart(double animationValue) {
    if (widget.points.isEmpty) {
      return Center(child: Text('No prediction data available'));
    }
    
    // Create spots for both actual and predicted data
    final List<FlSpot> actualSpots = [];
    final List<FlSpot> predictedSpots = [];
    
    for (int i = 0; i < widget.points.length; i++) {
      final point = widget.points[i];
      if (_showActual) {
        actualSpots.add(FlSpot(i.toDouble(), point.actual * animationValue));
      }
      if (_showPredicted) {
        predictedSpots.add(FlSpot(i.toDouble(), point.predicted * animationValue));
      }
    }
    
    // Extract day labels
    final List<String> days = widget.points.map((point) => point.day).toList();

    // Calculate min and max Y values based on visible data
    double minY = 5000;  // Default starting value
    double maxY = 8000;  // Default max value
    
    if (actualSpots.isNotEmpty || predictedSpots.isNotEmpty) {
      List<double> allYValues = [];
      
      if (actualSpots.isNotEmpty) {
        allYValues.addAll(actualSpots.map((spot) => spot.y));
      }
      
      if (predictedSpots.isNotEmpty) {
        allYValues.addAll(predictedSpots.map((spot) => spot.y));
      }
      
      if (allYValues.isNotEmpty) {
        minY = (allYValues.reduce((a, b) => a < b ? a : b) * 0.9).clamp(0, 10000);
        maxY = (allYValues.reduce((a, b) => a > b ? a : b) * 1.1).clamp(1000, 15000);
      }
    }
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
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
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                // Only show some labels to avoid crowding
                if (value % 1000 == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Text(
                      '${(value / 1000).toInt()}k',
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
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (days.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          if (_showActual)
            // Actual data line
            LineChartBarData(
              spots: actualSpots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
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
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          if (_showPredicted)
            // Predicted data line (dotted)
            LineChartBarData(
              spots: predictedSpots,
              isCurved: true,
              color: AppColors.secondary,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3.5,
                    color: AppColors.secondary,
                    strokeWidth: 1,
                    strokeColor: Colors.white,
                  );
                },
              ),
              dashArray: [5, 5], // Make the prediction line dotted
            ),
        ],
      ),
    );
  }
}