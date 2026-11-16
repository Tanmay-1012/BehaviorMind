import 'package:flutter/material.dart';
import 'package:behaviormind/theme/colors.dart';
import 'package:behaviormind/models/activity_model.dart';

class DailySummaryCard extends StatelessWidget {
  final String date;
  final String prediction;
  final MoodType mood;
  final int steps;
  final double screenHours;
  final String suggestion;
  final bool isSuggestionFollowed;

  const DailySummaryCard({
    super.key,
    required this.date,
    required this.prediction,
    required this.mood,
    required this.steps,
    required this.screenHours,
    required this.suggestion,
    required this.isSuggestionFollowed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Daily Summary',
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12.0),
          _buildPrediction(),
          const SizedBox(height: 16.0),
          _buildStats(),
          const SizedBox(height: 16.0),
          _buildSuggestion(),
        ],
      ),
    );
  }

  Widget _buildPrediction() {
    Color predictionColor;
    IconData predictionIcon;

    // Set color and icon based on prediction content
    if (prediction.contains('high focus')) {
      predictionColor = Colors.green;
      predictionIcon = Icons.check_circle;
    } else if (prediction.contains('risk')) {
      predictionColor = Colors.red;
      predictionIcon = Icons.error;
    } else if (prediction.contains('exceed')) {
      predictionColor = Colors.green;
      predictionIcon = Icons.check_circle;
    } else if (prediction.contains('slump')) {
      predictionColor = Colors.orange;
      predictionIcon = Icons.warning;
    } else if (prediction.contains('relaxation')) {
      predictionColor = Colors.green;
      predictionIcon = Icons.check_circle;
    } else {
      predictionColor = Colors.grey;
      predictionIcon = Icons.info;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prediction:',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4.0),
        Row(
          children: [
            Icon(
              predictionIcon,
              color: predictionColor,
              size: 18.0,
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                prediction,
                style: TextStyle(
                  fontSize: 14.0,
                  color: predictionColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStats() {
    IconData moodIcon;
    Color moodColor;

    switch (mood) {
      case MoodType.positive:
        moodIcon = Icons.sentiment_satisfied_alt;
        moodColor = Colors.green;
        break;
      case MoodType.negative:
        moodIcon = Icons.sentiment_dissatisfied;
        moodColor = Colors.red;
        break;
      case MoodType.neutral:
        moodIcon = Icons.sentiment_neutral;
        moodColor = Colors.orange;
        break;
      case MoodType.mixed:
        moodIcon = Icons.sentiment_neutral;
        moodColor = Colors.blue;
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              moodIcon,
              color: moodColor,
              size: 18.0,
            ),
            const SizedBox(width: 4.0),
            const Text(
              'Mood',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Icon(
              Icons.directions_walk,
              color: AppColors.primary,
              size: 18.0,
            ),
            const SizedBox(width: 4.0),
            Text(
              '$steps steps',
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Row(
          children: [
            const Icon(
              Icons.desktop_windows,
              color: AppColors.primary,
              size: 18.0,
            ),
            const SizedBox(width: 4.0),
            Text(
              '$screenHours hours Screen',
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuggestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.primary,
                  size: 18.0,
                ),
                SizedBox(width: 8.0),
                Text(
                  'Archived Suggestion:',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4.0),
        Text(
          suggestion,
          style: const TextStyle(
            fontSize: 14.0,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4.0),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          decoration: BoxDecoration(
            color: isSuggestionFollowed
                ? AppColors.primary.withAlpha((0.2 * 255).round())
                : Colors.grey.withAlpha((0.2 * 255).round()),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Text(
            isSuggestionFollowed ? 'Followed' : 'Not Followed',
            style: TextStyle(
              fontSize: 12.0,
              color: isSuggestionFollowed ? AppColors.primary : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
