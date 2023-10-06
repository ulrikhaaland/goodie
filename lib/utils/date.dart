import 'package:intl/intl.dart';

String getCurrentDay() {
  final weekdays = [
    'Mandag',
    'Tirsdag',
    'Onsdag',
    'Torsdag',
    'Fredag',
    'Lørdag',
    'Søndag'
  ];
  return weekdays[DateTime.now().weekday - 1];
}

String getTodayOpeningHours(String openingHours) {
  final today = getCurrentDay();
  final regex = RegExp(r'(\d{2}:\d{2}–\d{2}:\d{2})');
  final startIndex = openingHours.indexOf(today);
  if (startIndex != -1) {
    final match = regex.firstMatch(openingHours.substring(startIndex));
    if (match != null) {
      return match.group(1) ?? ''; // Returns the matched time range.
    }
  }
  return ''; // Return empty string if no matching time is found.
}

String formatTimestamp(DateTime timestamp) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final aWeekAgo = today.subtract(const Duration(days: 7));

  if (timestamp.isAfter(today)) {
    return 'Today';
  } else if (timestamp.isAfter(yesterday)) {
    return 'Yesterday';
  } else if (timestamp.isAfter(aWeekAgo)) {
    final daysAgo = now.difference(timestamp).inDays;
    return daysAgo == 1 ? '$daysAgo day ago' : '$daysAgo days ago';
  } else {
    if (timestamp.year == now.year) {
      return DateFormat('MMMM').format(timestamp); // e.g., January
    } else {
      return DateFormat('MMMM y').format(timestamp); // e.g., January 2022
    }
  }
}
