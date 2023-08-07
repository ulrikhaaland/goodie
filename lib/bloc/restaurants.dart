import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goodie/model/restaurant.dart';

class RestaurantProvider with ChangeNotifier {
  List<Restaurant> _restaurants = [];

  List<Restaurant> get restaurants => _restaurants;

  DocumentSnapshot?
      _lastRestaurantDocument; // Tracks the last document in the current list

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
        position: null,
      );

      _restaurants.add(restaurant);
    }

    _lastRestaurantDocument = restaurantSnapshot
        .docs.last; // Save the last document for the next fetch
    notifyListeners(); // Notify listeners to refresh UI
  }

  Future<void> fetchMoreRestaurants(int limit) async {
    if (_lastRestaurantDocument == null) {
      return fetchRestaurants(); // If no previous document, start from the beginning
    }

    final restaurantCollection =
        FirebaseFirestore.instance.collection('restaurants');

    // Start the query after the last document retrieved in the previous fetch
    final restaurantSnapshot = await restaurantCollection
        .startAfterDocument(_lastRestaurantDocument!)
        .limit(limit)
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
          position: null,
        );

        _restaurants.add(restaurant);
      }

      notifyListeners(); // Notify listeners to refresh UI
    }
  }

  Future<void> fetchDishesAndPrecacheImages(
      String restaurantId, BuildContext context) async {
    final dishesCollection = FirebaseFirestore.instance
        .collection('restaurants')
        .doc(restaurantId)
        .collection('dishes');

    final dishSnapshot = await dishesCollection.get();

    List<Dish> dishes = dishSnapshot.docs.map((dishDoc) {
      // Check the type and existence of each field before accessing it
      String name = dishDoc['name'] is String ? dishDoc['name'] : '';
      name = name.replaceAll('*', '').trim();
      String description =
          dishDoc['description'] is String ? dishDoc['description'] : '';
      num price = dishDoc['price'] is num ? dishDoc['price'] : 0;
      String imgUrl = dishDoc['img_url'] is String ? dishDoc['img_url'] : '';
      bool popular = dishDoc['popular'] is bool ? dishDoc['popular'] : false;

      return Dish(
        restaurantId: restaurantId,
        name: name,
        description: description,
        price: price,
        imgUrl: imgUrl,
        popular: popular,
      );
    }).toList();

    // Sort the dishes based on popularity and price
    dishes.sort((a, b) {
      if (a.popular == b.popular) {
        return b.price.compareTo(
            a.price); // If popularity is equal, sort by price from high to low
      } else {
        return (b.popular ? 1 : 0) - (a.popular ? 1 : 0); // Sort by popularity
      }
    });

    // Precache the images
    for (var dish in dishes
        .where(
            (element) => element.imgUrl != null && element.imgUrl!.isNotEmpty)
        .take(8)) {
      // ignore: use_build_context_synchronously
      await precacheImage(NetworkImage(dish.imgUrl ?? ''), context);
    }

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
