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
