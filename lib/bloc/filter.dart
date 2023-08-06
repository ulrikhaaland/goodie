import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

import '../model/restaurant.dart';

enum FilterCriteria { recommended, distance, rating, price }

class RestaurantFilter {
  final Set<String> categories;
  final String? name;
  final FilterCriteria? criteria;
  final num?
      ratingThreshold; // e.g. if you want to show restaurants above 4.5 rating
  bool isActive;

  RestaurantFilter({
    required this.categories,
    this.name,
    this.criteria,
    this.ratingThreshold,
    this.isActive = false,
  });
}

class FilterProvider with ChangeNotifier {
  RestaurantFilter _filter = RestaurantFilter(
    categories: {},
    name: null,
    criteria: null,
    ratingThreshold: null,
    isActive: false,
  );

  RestaurantFilter get filter => _filter;
  Map<String, int> categoryCounts = {};
  List<String> uniqueCategories = [];

  void countCategoryAppearances(List<Restaurant> restaurants) {
    for (var restaurant in restaurants) {
      for (var category in restaurant.categories) {
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }
    }
    _populateUniqueCategories();
  }

  void _populateUniqueCategories() {
    // Optionally: Filter categories that appear less than a certain number of times
    // final threshold = 5;
    // categoryCounts.removeWhere((key, value) => value < threshold);

    // Sort categories based on their count, from highest to lowest
    uniqueCategories = categoryCounts.keys.toList()
      ..sort((a, b) => categoryCounts[b]!.compareTo(categoryCounts[a]!));
  }

  set categories(Set<String> newCategories) {
    _filter = RestaurantFilter(
      categories: newCategories,
      name: _filter.name,
      criteria: _filter.criteria,
      ratingThreshold: _filter.ratingThreshold,
    );
    notifyListeners();
  }

  set name(String? newName) {
    _filter = RestaurantFilter(
      categories: _filter.categories,
      name: newName,
      criteria: _filter.criteria,
      ratingThreshold: _filter.ratingThreshold,
    );
    notifyListeners();
  }

  set criteria(FilterCriteria? newCriteria) {
    _filter = RestaurantFilter(
      categories: _filter.categories,
      name: _filter.name,
      criteria: newCriteria,
      ratingThreshold: _filter.ratingThreshold,
    );
    notifyListeners();
  }

  set ratingThreshold(num? newRating) {
    _filter = RestaurantFilter(
      categories: _filter.categories,
      name: _filter.name,
      criteria: _filter.criteria,
      ratingThreshold: newRating,
    );
    notifyListeners();
  }

  set active(bool newActive) {
    _filter.isActive = newActive;
    notifyListeners();
  }

  List<Restaurant> applyFilter(
      List<Restaurant> restaurants, LocationData? userLocation) {
    // Check if userLocation is null, and if so, create a LatLng with default values
    LatLng userLatLng = userLocation != null
        ? LatLng(userLocation.latitude!, userLocation.longitude!)
        : LatLng(0, 0); // Default values, or you could handle this differently

    return restaurants.where((restaurant) {
      bool matchesFilter = true;

      // ... [rest of the filtering logic]

      return matchesFilter;
    }).toList()
      ..sort((a, b) {
        final distance = Distance();

        switch (_filter.criteria) {
          case FilterCriteria.recommended:
            return (b.rating ?? 0).compareTo(a.rating ?? 0);
          case FilterCriteria.distance:
            // Only calculate distances if userLocation is not null
            if (userLocation != null) {
              double aDistance = a.position != null
                  ? distance(userLatLng, a.position!)
                  : double.infinity;
              double bDistance = b.position != null
                  ? distance(userLatLng, b.position!)
                  : double.infinity;
              return aDistance.compareTo(bDistance);
            }
            return 0; // Return 0 if userLocation is null
          case FilterCriteria.rating:
            return (b.rating ?? 0).compareTo(a.rating ?? 0);
          case FilterCriteria.price:
            return (a.priceLevel ?? 0).compareTo(b.priceLevel ?? 0);
          case null:
          default:
            return 0; // No specific sorting or unhandled criteria
        }
      });
  }
}
