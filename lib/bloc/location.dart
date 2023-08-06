import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationProvider with ChangeNotifier {
  final Location _location = Location();
  LocationData? _currentLocation;

  LocationData? get currentLocation => _currentLocation;

  LocationProvider() {
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentLocation = await _location.getLocation();
    _location.onLocationChanged.listen((LocationData locationData) {
      _currentLocation = locationData;
      notifyListeners();
    });
  }

  Future<void> updateLocation() async {
    _currentLocation = await _location.getLocation();
    notifyListeners();
  }
}
