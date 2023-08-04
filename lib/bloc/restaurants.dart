import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goodie/model/restaurant.dart';

class RestaurantProvider with ChangeNotifier {
  List<Restaurant> _restaurants = [];

  List<Restaurant> get restaurants => _restaurants;

  Future<void> fetchRestaurants() async {
    _restaurants = []; // Reset the restaurants list

    final restaurantCollection =
        FirebaseFirestore.instance.collection('restaurants');

    final restaurantSnapshot = await restaurantCollection.limit(50).get();

    for (var restaurantDoc in restaurantSnapshot.docs) {
      Restaurant restaurant = Restaurant(
        id: restaurantDoc.id,
        name: restaurantDoc['name'],
        address: restaurantDoc['address'],
        description: restaurantDoc['description'],
        rating: restaurantDoc['rating'],
        priceLevel: restaurantDoc['priceLevel'],
        coverImg: restaurantDoc['coverImg'],
        openingHours: restaurantDoc['openingHours'],
        homepage: restaurantDoc['homepage'],
        phone: restaurantDoc['phone'],
        dishes: [], // No dishes are fetched
        categories: Set.from(restaurantDoc['categories']),
        reviews: [],
      );

      _restaurants.add(restaurant);
    }

    _lastRestaurantDocument = restaurantSnapshot
        .docs.last; // Save the last document for the next fetch

    notifyListeners(); // Notify listeners to refresh UI
  }

  DocumentSnapshot?
      _lastRestaurantDocument; // Tracks the last document in the current list

  Future<void> fetchMoreRestaurants() async {
    if (_lastRestaurantDocument == null) {
      return fetchRestaurants(); // If no previous document, start from the beginning
    }

    final restaurantCollection =
        FirebaseFirestore.instance.collection('restaurants');

    // Start the query after the last document retrieved in the previous fetch
    final restaurantSnapshot = await restaurantCollection
        .startAfterDocument(_lastRestaurantDocument!)
        .limit(50)
        .get();

    if (restaurantSnapshot.docs.isNotEmpty) {
      _lastRestaurantDocument = restaurantSnapshot
          .docs.last; // Save the last document for the next fetch

      for (var restaurantDoc in restaurantSnapshot.docs) {
        Restaurant restaurant = Restaurant(
          id: restaurantDoc.id,
          name: restaurantDoc['name'],
          address: restaurantDoc['address'],
          description: restaurantDoc['description'],
          rating: restaurantDoc['rating'],
          priceLevel: restaurantDoc['priceLevel'],
          coverImg: restaurantDoc['coverImg'],
          openingHours: restaurantDoc['openingHours'],
          homepage: restaurantDoc['homepage'],
          phone: restaurantDoc['phone'],
          dishes: [], // No dishes are fetched
          categories: Set.from(restaurantDoc['categories']),
          reviews: [],
        );

        _restaurants.add(restaurant);
      }

      notifyListeners(); // Notify listeners to refresh UI
    }
  }

  Future<void> fetchDishesForRestaurant(String restaurantId) async {
    final dishesCollection = FirebaseFirestore.instance
        .collection('restaurants')
        .doc(restaurantId)
        .collection('dishes');

    final dishSnapshot = await dishesCollection.get();

    List<Dish> dishes = dishSnapshot.docs.map((dishDoc) {
      return Dish(
        restaurantId: restaurantId,
        name: dishDoc['name'],
        description: dishDoc['description'],
        price: dishDoc['price'],
        imgUrl: dishDoc['imgUrl'],
        popular: dishDoc['popular'],
      );
    }).toList();

    // Update the restaurant's dishes
    int restaurantIndex = _restaurants.indexWhere((r) => r.id == restaurantId);
    if (restaurantIndex != -1) {
      Restaurant restaurant = _restaurants[restaurantIndex];
      restaurant.dishes = dishes;
      _restaurants[restaurantIndex] = restaurant;
      notifyListeners(); // Notify listeners to refresh UI
    } else {
      // Handle error: Restaurant not found
    }
  }
}
