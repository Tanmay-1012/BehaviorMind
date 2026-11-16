// Remove old import if it exists, not strictly needed as ForegroundAppUsageInfo is not used here directly
// import 'package:app_usage/app_usage.dart'; 

enum AppCategory {
  social,
  games,
  productivity,
  communication,
  entertainment,
  informationNews,
  toolsUtilities,
  healthFitness,
  shopping,
  finance,
  education,
  travel,
  lifestyle,
  other,
}

class AppCategoryService {
  // Updated to accept packageName and appName directly
  static AppCategory categorizeApp({required String packageName, String? appName}) {
    final String lowerPackageName = packageName.toLowerCase();
    final String lowerAppName = (appName ?? '').toLowerCase(); // Handle null appName

    if (lowerPackageName.contains('facebook') ||
        lowerPackageName.contains('instagram') ||
        lowerPackageName.contains('twitter') ||
        lowerPackageName.contains('snapchat') ||
        lowerPackageName.contains('tiktok') ||
        lowerPackageName.contains('linkedin') ||
        lowerAppName.contains('social')) {
      return AppCategory.social;
    }
    if (lowerPackageName.contains('game') ||
        lowerAppName.contains('game') ||
        lowerPackageName.contains('clash') ||
        lowerPackageName.contains('candycrush') ||
        lowerAppName.contains('pokemon')) {
      return AppCategory.games;
    }
    if (lowerPackageName.contains('whatsapp') ||
        lowerPackageName.contains('messenger') ||
        lowerPackageName.contains('telegram') ||
        lowerPackageName.contains('signal') ||
        lowerPackageName.contains('discord') ||
        lowerAppName.contains('chat') ||
        lowerAppName.contains('message')) {
      return AppCategory.communication;
    }
    if (lowerPackageName.contains('youtube') ||
        lowerPackageName.contains('netflix') ||
        lowerPackageName.contains('spotify') ||
        lowerPackageName.contains('hulu') ||
        lowerPackageName.contains('disney') ||
        lowerAppName.contains('music') ||
        lowerAppName.contains('video') ||
        lowerAppName.contains('stream')) {
      return AppCategory.entertainment;
    }
     if (lowerPackageName.contains('chrome') ||
        lowerPackageName.contains('firefox') ||
        lowerPackageName.contains('browser') ||
        lowerPackageName.contains('news') ||
        lowerPackageName.contains('reddit') ||
        lowerAppName.contains('news') ||
        lowerAppName.contains('browse')) {
      return AppCategory.informationNews;
    }
    if (lowerPackageName.contains('docs') ||
        lowerPackageName.contains('sheets') ||
        lowerPackageName.contains('slides') ||
        lowerPackageName.contains('office') ||
        lowerPackageName.contains('drive') ||
        lowerPackageName.contains('microsoft.office') ||
        lowerPackageName.contains('adobe') ||
        lowerAppName.contains('work') ||
        lowerAppName.contains('note') ||
        lowerAppName.contains('calendar')) {
      return AppCategory.productivity;
    }
    if (lowerPackageName.contains('maps') ||
        lowerPackageName.contains('uber') ||
        lowerPackageName.contains('lyft') ||
        lowerAppName.contains('navigate') ||
        lowerAppName.contains('travel') ||
        lowerAppName.contains('flight') ||
        lowerAppName.contains('hotel')) {
      return AppCategory.travel;
    }
     if (lowerPackageName.contains('amazon') ||
        lowerPackageName.contains('ebay') ||
        lowerPackageName.contains('etsy') ||
        lowerAppName.contains('shop') ||
        lowerAppName.contains('store')) {
      return AppCategory.shopping;
    }
    if (lowerPackageName.contains('calculator') ||
        lowerPackageName.contains('clock') ||
        lowerPackageName.contains('tool') ||
        lowerAppName.contains('utility') ||
        lowerAppName.contains('file')) {
      return AppCategory.toolsUtilities;
    }
    // Add more rules as needed

    return AppCategory.other;
  }

  static String categoryToString(AppCategory category) {
    switch (category) {
      case AppCategory.social:
        return 'Social';
      case AppCategory.games:
        return 'Games';
      case AppCategory.productivity:
        return 'Productivity';
      case AppCategory.communication:
        return 'Communication';
      case AppCategory.entertainment:
        return 'Entertainment';
      case AppCategory.informationNews:
        return 'Information & News';
      case AppCategory.toolsUtilities:
        return 'Tools & Utilities';
      case AppCategory.healthFitness:
        return 'Health & Fitness';
      case AppCategory.shopping:
        return 'Shopping';
      case AppCategory.finance:
        return 'Finance';
      case AppCategory.education:
        return 'Education';
      case AppCategory.travel:
        return 'Travel & Local';
      case AppCategory.lifestyle:
        return 'Lifestyle';
      case AppCategory.other:
        return 'Other';
    }
  }
} 