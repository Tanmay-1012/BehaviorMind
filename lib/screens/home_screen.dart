import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:behaviormind/providers/health_data_provider.dart';
import 'package:behaviormind/providers/prediction_provider.dart';
import 'package:behaviormind/providers/user_provider.dart';
import 'package:behaviormind/routes.dart';
import 'package:behaviormind/theme/colors.dart';
import 'package:behaviormind/models/health_data_model.dart';
import 'package:behaviormind/utils/date_formatter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:behaviormind/widgets/activity_detail_modal.dart';
import 'package:behaviormind/widgets/historical_activity_list.dart';
import 'package:behaviormind/screens/sleep_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    
    // Sync health data on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final healthProvider = Provider.of<HealthDataProvider>(context, listen: false);
      healthProvider.syncHealthData();
      
      // Generate prediction if needed
      final predictionProvider = Provider.of<PredictionProvider>(context, listen: false);
      if (predictionProvider.isPredictionNeeded()) {
        predictionProvider.generatePrediction();
      }
    });
  }
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Navigate to the appropriate screen based on the selected index
    switch (index) {
      case 0:
        // Already on home screen
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.predict);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.archive);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final healthProvider = Provider.of<HealthDataProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final predictionProvider = Provider.of<PredictionProvider>(context);
    
    final healthData = healthProvider.latestHealthData;
    final user = userProvider.user;
    final currentViewDate = healthProvider.currentViewDate;
    final isViewingToday = DateFormatter.isToday(currentViewDate);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('BehaviorMind'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {
              _showNotificationsPanel(context);
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
      body: user == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome section
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        child: Icon(Icons.person, size: 32, color: Colors.white),
                        backgroundColor: AppColors.primary.withOpacity(0.8),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            user.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Date navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isViewingToday ? "Today's Overview" : "Daily Overview",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios, size: 18),
                            onPressed: () {
                              healthProvider.navigateToPreviousDay();
                            },
                          ),
                          Text(
                            DateFormatter.formatReadable(currentViewDate),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_forward_ios, size: 18),
                            onPressed: isViewingToday 
                                ? null 
                                : () => healthProvider.navigateToNextDay(),
                            color: isViewingToday ? Colors.grey.withOpacity(0.5) : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Health stats cards - new dark style
                  if (healthData != null)
                    Column(
                      children: [
                        // First row - 3 cards
                        Row(
                          children: [
                            Expanded(child: _buildStatCard(
                              context, 'Steps', '${healthData.steps} steps',
                              Icons.directions_run, AppColors.primary.withOpacity(0.8)
                            )),
                            SizedBox(width: 12),
                            Expanded(child: _buildStatCard(
                              context, 'Calories', '${healthData.caloriesBurned} kcal',
                              Icons.local_fire_department, Colors.orange.withOpacity(0.8)
                            )),
                            SizedBox(width: 12),
                            Expanded(child: _buildStatCard(
                              context, 'Heart Rate', '${healthData.heartRate} bpm', 
                              Icons.favorite, Colors.red.withOpacity(0.8)
                            )),
                          ],
                        ),
                        
                        SizedBox(height: 12),
                        
                        // Second row - 3 cards
                        Row(
                          children: [
                            Expanded(child: _buildStatCard(
                              context, 'Screen Time', '5h 29m',
                              Icons.phone_android, Colors.blue.withOpacity(0.8)
                            )),
                            SizedBox(width: 12),
                            Expanded(child: _buildStatCard(
                              context, 'Blood Oxygen', '98%',
                              Icons.bloodtype, Colors.green.withOpacity(0.8)
                            )),
                            SizedBox(width: 12),
                            Expanded(child: _buildStatCard(
                              context, 'Stress Level', 'Low',
                              Icons.psychology, Colors.purple.withOpacity(0.8)
                            )),
                          ],
                        ),
                        
                        SizedBox(height: 16),
                        
                        // Sleep breakdown card
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context) => SleepDetailsScreen(
                                  sleepData: healthData.sleep,
                                  date: currentViewDate.toString(),
                                ),
                              ),
                            );
                          },
                          child: _buildSleepCard(context, healthData.sleep),
                        ),
                      ],
                    )
                  else
                    Center(child: CircularProgressIndicator()),
                  
                  const SizedBox(height: 24),
                  
                  // Behavior insights
                  _buildInsightsCard(context, predictionProvider),
                  
                  const SizedBox(height: 24),
                  
                  // Weekly activity chart
                  _buildWeeklyActivityCard(context, healthProvider),
                  
                  const SizedBox(height: 24),
                  
                  // Past 15 days activities
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Past 15 Days Activity",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.archive);
                        },
                        child: Text("View All"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Historical activity list
                  HistoricalActivityList(
                    activities: healthProvider.getActivityHistory(),
                  ),
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
  
  // New style stat card with black background
  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        _showDetailView(context, title, value, icon, color);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  // Detailed sleep breakdown card
  Widget _buildSleepCard(BuildContext context, SleepData sleep) {
    // Calculate percentages for display
    final totalHours = sleep.totalHours;
    final deepPercent = sleep.deepSleepHours / totalHours * 100;
    final lightPercent = sleep.lightSleepHours / totalHours * 100;
    final remPercent = sleep.remSleepHours / totalHours * 100;
    final awakePercent = sleep.awakeSleepHours / totalHours * 100;
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.nightlight_round, color: AppColors.secondary),
              SizedBox(width: 8),
              Text(
                'Sleep Analysis',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${sleep.totalHours.toStringAsFixed(1)} hours',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getSleepQualityColor(sleep.totalHours).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getSleepQualityText(sleep.totalHours),
                  style: TextStyle(
                    color: _getSleepQualityColor(sleep.totalHours),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          // Sleep phase breakdown bars
          Row(
            children: [
              Expanded(
                flex: deepPercent.round(),
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      bottomLeft: Radius.circular(6),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: lightPercent.round(),
                child: Container(
                  height: 12,
                  color: Colors.blue.shade300,
                ),
              ),
              Expanded(
                flex: remPercent.round(),
                child: Container(
                  height: 12,
                  color: Colors.purple.shade300,
                ),
              ),
              Expanded(
                flex: awakePercent.round(),
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Sleep phases legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSleepLegendItem(context, 'Deep', Colors.indigo, 
                  '${sleep.deepSleepHours.toStringAsFixed(1)}h'),
              _buildSleepLegendItem(context, 'Light', Colors.blue.shade300, 
                  '${sleep.lightSleepHours.toStringAsFixed(1)}h'),
              _buildSleepLegendItem(context, 'REM', Colors.purple.shade300, 
                  '${sleep.remSleepHours.toStringAsFixed(1)}h'),
              _buildSleepLegendItem(context, 'Awake', Colors.grey.shade400, 
                  '${sleep.awakeSleepHours.toStringAsFixed(1)}h'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSleepLegendItem(BuildContext context, String label, Color color, String value) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
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
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Color _getSleepQualityColor(double hours) {
    if (hours >= 7.5) return Colors.green;
    if (hours >= 6.0) return Colors.orange;
    return Colors.red;
  }
  
  String _getSleepQualityText(double hours) {
    if (hours >= 7.5) return 'Good';
    if (hours >= 6.0) return 'Fair';
    return 'Poor';
  }
  
  Widget _buildInsightsCard(BuildContext context, PredictionProvider predictionProvider) {
    final prediction = predictionProvider.latestPrediction;
    
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
              children: [
                Icon(Icons.lightbulb, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  'Today\'s Insights',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(height: 24),
            if (prediction != null) ...[
              _buildInsightItem(
                context,
                'Mental Wellness',
                prediction.mentalFatiguePrediction,
                Icons.psychology,
                AppColors.primary,
              ),
              const SizedBox(height: 12),
              _buildInsightItem(
                context,
                'Physical Activity',
                'You\'re likely to reach 85% of your step goal today based on your current activity pattern.',
                Icons.directions_run,
                AppColors.secondary,
              ),
              const SizedBox(height: 12),
              _buildInsightItem(
                context,
                'Sleep Pattern',
                'Your sleep duration has been consistent over the past week, with an average of 7.2 hours per night.',
                Icons.nightlight_round,
                AppColors.accent,
              ),
            ] else ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ],
        ),
      ),
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
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
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
  
  Widget _buildWeeklyActivityCard(BuildContext context, HealthDataProvider healthProvider) {
    // Get health data for past week
    final now = DateTime.now();
    final weekAgo = now.subtract(Duration(days: 7));
    final weeklyData = healthProvider.getHealthDataForRange(weekAgo, now);
    
    // Create data points for chart
    final List<FlSpot> stepSpots = [];
    final List<String> labels = [];
    
    // Create 7 days of sample data
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      labels.add(_getDayLabel(day));
      
      // Generate a somewhat realistic step pattern
      double steps = 0;
      
      // If we have data for this day, use it
      final matchingData = weeklyData.where((data) => 
        data.date == '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}'
      ).toList();
      
      if (matchingData.isNotEmpty) {
        steps = matchingData.first.steps / 1000; // Convert to K
      } else {
        // Generate some placeholder data
        steps = 5.0 + (day.day % 5) * 0.8;
      }
      
      stepSpots.add(FlSpot((6 - i).toDouble(), steps));
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
              'Weekly Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: stepSpots.isNotEmpty
                  ? LineChart(
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
                                if (value.toInt() >= 0 && value.toInt() < labels.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      labels[value.toInt()],
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
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
                                    '${value.toInt()}K',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
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
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: stepSpots,
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
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.primary.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Center(child: CircularProgressIndicator()),
            ),
          ],
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
  
  void _showDetailView(BuildContext context, String title, String value, IconData icon, Color color) {
    final healthProvider = Provider.of<HealthDataProvider>(context, listen: false);
    final healthData = healthProvider.latestHealthData;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;
    
    // Generate chart data
    List<FlSpot> getChartData() {
      switch (title) {
        case 'Steps':
          return List.generate(12, (i) => FlSpot(i.toDouble(), 250 + (i * 20) % 500));
        case 'Sleep':
          return List.generate(12, (i) => FlSpot(i.toDouble(), 0.5 + (i * 0.15) % 1.0));
        case 'Heart Rate':
          return List.generate(12, (i) => FlSpot(i.toDouble(), 65 + (i * 4) % 20));
        case 'Calories':
          return List.generate(12, (i) => FlSpot(i.toDouble(), 50 + (i * 5) % 100));
        case 'Screen Time':
          return List.generate(12, (i) => FlSpot(i.toDouble(), 0.2 + (i * 0.05) % 0.5));
        default:
          return List.generate(12, (i) => FlSpot(i.toDouble(), 20 + (i * 10) % 40));
      }
    }
    
    // Determine units and goals
    String unit = '';
    double goalValue = 0;
    String goalUnit = '';
    double progressValue = 0;
    
    switch (title) {
      case 'Steps':
        unit = 'steps';
        goalValue = user?.healthGoals['steps']?.toDouble() ?? 10000;
        goalUnit = 'steps';
        progressValue = healthData?.steps?.toDouble() ?? 0;
        break;
      case 'Sleep':
        unit = 'hrs';
        goalValue = user?.healthGoals['sleep']?.toDouble() ?? 8;
        goalUnit = 'hours';
        progressValue = healthData?.sleep.totalHours ?? 0;
        break;
      case 'Heart Rate':
        unit = 'bpm';
        goalValue = 80;
        goalUnit = 'bpm';
        progressValue = healthData?.heartRate?.toDouble() ?? 0;
        break;
      case 'Calories':
        unit = 'kcal';
        goalValue = 2000;
        goalUnit = 'kcal';
        progressValue = healthData?.caloriesBurned?.toDouble() ?? 0;
        break;
      case 'Screen Time':
        unit = 'hrs';
        goalValue = 3;
        goalUnit = 'hours';
        progressValue = 5.5;
        break;
      default:
        unit = '';
        goalValue = 100;
        goalUnit = '';
        progressValue = 50;
    }
    
    // Extract numeric value if needed
    String numericValue = value;
    if (value.contains(' ')) {
      numericValue = value.split(' ')[0];
    }
    
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
              title: title,
              value: numericValue,
              unit: unit,
              icon: icon,
              color: color,
              progress: progressValue,
              goal: goalValue,
              goalUnit: goalUnit,
              chartData: getChartData(),
              extraData: {
                'date': DateFormatter.formatIso(healthProvider.currentViewDate),
                'screenTime': 5.5,
                'mood': 'MoodType.positive',
                'suggestions': [
                  'Consider taking a short walk in the afternoon to boost your step count.',
                  'Your screen time is slightly higher than average. Try setting app limits.',
                  'Your sleep pattern shows less deep sleep than optimal. Consider going to bed 30 minutes earlier.'
                ],
              },
            ),
          );
        },
      ),
    );
  }
  
  void _showNotificationsPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Notifications',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    _buildNotificationItem(
                      context, 
                      'Daily Goal Reached!', 
                      'You reached your step goal for today. Keep it up!',
                      Icons.directions_walk,
                      AppColors.success,
                      '5 min ago',
                    ),
                    _buildNotificationItem(
                      context, 
                      'New Behavior Insight', 
                      'We\'ve detected a pattern in your sleep habits. Check it out.',
                      Icons.insights,
                      AppColors.primary,
                      '2 hours ago',
                    ),
                    _buildNotificationItem(
                      context, 
                      'Reminder', 
                      'Time to take a break from screen time.',
                      Icons.timer,
                      AppColors.warning,
                      'Yesterday',
                    ),
                    _buildNotificationItem(
                      context, 
                      'Weekly Summary Ready', 
                      'Your weekly activity report is available. See how you did!',
                      Icons.assessment,
                      AppColors.accent,
                      '2 days ago',
                    ),
                    _buildNotificationItem(
                      context, 
                      'New Suggestion', 
                      'Based on your recent activity, we have a new recommendation for you.',
                      Icons.lightbulb,
                      AppColors.moodPositive,
                      '3 days ago',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildNotificationItem(
    BuildContext context,
    String title,
    String message,
    IconData icon,
    Color color,
    String timeAgo,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}