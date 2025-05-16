import 'package:intl/intl.dart';

class DateFormatter {
  // Format date as 'May 15, 2025'
  static String formatFullDate(DateTime date) {
    return DateFormat('MMMM d, y').format(date);
  }
  
  // Format date as 'May 15'
  static String formatMonthDay(DateTime date) {
    return DateFormat('MMMM d').format(date);
  }
  
  // Format date as '2025-05-15'
  static String formatIso(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  // Format date as 'May 15, 2025' from ISO string
  static String formatIsoToFull(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return formatFullDate(date);
    } catch (e) {
      return isoDate; // Return original if parsing fails
    }
  }
  
  // Parse a date from 'May 15, 2025' format
  static DateTime parseFromFullDate(String fullDate) {
    return DateFormat('MMMM d, y').parse(fullDate);
  }
  
  // Format date as 'May 15' from ISO string
  static String formatIsoToMonthDay(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return formatMonthDay(date);
    } catch (e) {
      return isoDate; // Return original if parsing fails
    }
  }
  
  // Format date as 'Mon', 'Tue', etc.
  static String formatDayOfWeek(DateTime date) {
    return DateFormat('E').format(date);
  }
  
  // Format time as '8:30 AM'
  static String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }
  
  // Get day of week from ISO string
  static String getDayOfWeekFromIso(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return formatDayOfWeek(date);
    } catch (e) {
      return ''; // Return empty string if parsing fails
    }
  }
  
  // Calculate age from birth date
  static int calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    
    // Adjust age if birthday hasn't occurred yet this year
    final birthdayThisYear = DateTime(today.year, birthDate.month, birthDate.day);
    if (today.isBefore(birthdayThisYear)) {
      age--;
    }
    
    return age;
  }
  
  // Calculate age from birth date string (format: 'January 1, 1994')
  static int calculateAgeFromString(String birthDateString) {
    try {
      final birthDate = DateFormat('MMMM d, y').parse(birthDateString);
      return calculateAge(birthDate);
    } catch (e) {
      print('Error parsing birth date: $e');
      return 0;
    }
  }
  
  // Get list of dates for the past n days
  static List<DateTime> getPastDays(int count) {
    final List<DateTime> dates = [];
    final today = DateTime.now();
    
    for (int i = count - 1; i >= 0; i--) {
      dates.add(today.subtract(Duration(days: i)));
    }
    
    return dates;
  }
  
  // Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
  
  // Check if a date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }
  
  // Get a human-readable relative date string (e.g., 'Today', 'Yesterday', 'May 15')
  static String getRelativeDateString(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else {
      return formatMonthDay(date);
    }
  }
  
  // Format date as 'May 15, 2025' or 'Today' if it's today
  static String formatReadable(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else {
      return formatFullDate(date);
    }
  }
}
