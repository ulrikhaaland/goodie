import 'dart:math';

double getDistance(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371.0; // Radius of the Earth in kilometers

  double dLat = _degreesToRadians(lat2 - lat1);
  double dLon = _degreesToRadians(lon2 - lon1);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degreesToRadians(lat1)) *
          cos(_degreesToRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  // returns distance in meters
  return (R * c) / 1000;
}

double _degreesToRadians(double degrees) {
  return degrees * pi / 180;
}

String extractCity(String? address) {
  if (address == null) return '';

  // Find the position of the last number in the address string
  final lastNumberIndex = address.lastIndexOf(RegExp(r'\d'));

  // If there's no number in the address, return an empty string
  if (lastNumberIndex == -1) return '';

  // Extract the substring that comes after the last number
  final citySubstring = address.substring(lastNumberIndex + 1);

  // Trim any leading or trailing whitespace to get the city name
  final cityName = citySubstring.trim();

  return cityName;
}
