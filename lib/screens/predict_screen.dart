import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:behaviormind/providers/prediction_provider.dart';
import 'package:behaviormind/routes.dart';
import 'package:behaviormind/theme/colors.dart';
import 'package:behaviormind/models/prediction_model.dart';
import 'package:behaviormind/widgets/prediction_chart.dart';

class PredictScreen extends StatefulWidget {
  const PredictScreen({Key? key}) : super(key: key);

  @override
  _PredictScreenState createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen> {
  int _selectedIndex = 1;
  
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
        // Already on predict screen
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
    final predictionProvider = Provider.of<PredictionProvider>(context);
    final prediction = predictionProvider.latestPrediction;
    final weeklyPoints = predictionProvider.weeklyPredictionPoints;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Behavior Prediction'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              predictionProvider.generatePrediction();
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
      body: prediction == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weekly activity prediction chart
                  PredictionChart(
                    points: weeklyPoints,
                    title: 'Activity Prediction',
                    description: 'Based on your current activity level, we predict a slightly above-average step count for the upcoming week, with higher activity levels during the weekdays and weekends.',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Mental fatigue prediction
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? AppColors.darkSecondary 
                        : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.psychology, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Mental Fatigue Prediction:',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            prediction.mentalFatiguePrediction,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Key insights and recommendations
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? AppColors.darkSecondary 
                        : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Key Insights & Recommendations:',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'The user\'s high social media usage could be a contributing factor to their afternoon stress. While their diet and physical activity are positive, the sleep duration (7 hours) and breakdown (Deep 1.5h, Light 4h, REM 1.5h, Awake 0.5h) might not be optimal for full cognitive recovery. Monitoring the correlation between social media usage, sleep quality, and reported stress levels could provide further insights.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          
                          // Factor correlations
                          Text(
                            'Factor Correlations:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...prediction.factorCorrelations.entries.map((entry) => 
                            _buildCorrelationItem(
                              context, 
                              _formatFactorName(entry.key), 
                              entry.value,
                            ),
                          ),
                        ],
                      ),
                    ),
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
  

  
  Widget _buildCorrelationItem(BuildContext context, String factor, double correlation) {
    // Determine color based on correlation value
    final Color color = correlation > 0 
        ? AppColors.success 
        : AppColors.error;
    
    // Format correlation as percentage
    final String formattedCorrelation = '${(correlation * 100).abs().toStringAsFixed(0)}%';
    
    // Correlation direction icon
    final IconData directionIcon = correlation > 0 
        ? Icons.arrow_upward 
        : Icons.arrow_downward;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(directionIcon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              factor,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            formattedCorrelation,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatFactorName(String key) {
    // Convert camelCase to Title Case with spaces
    final formattedKey = key.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
    
    // Capitalize first letter
    return formattedKey.substring(0, 1).toUpperCase() + formattedKey.substring(1);
  }
}