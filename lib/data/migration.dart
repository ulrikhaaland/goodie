import 'package:goodie/model/restaurant.dart';
import 'package:supabase/supabase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataMigration {
  final SupabaseClient supabaseClient;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  DataMigration(String supabaseUrl, String supabaseApiKey)
      : supabaseClient = SupabaseClient(supabaseUrl, supabaseApiKey);

  Future<List<Restaurant>> fetchRestaurants() async {
    final restaurantsResponse =
        await supabaseClient.from('restaurants').select().order('id');

    // Fetching restaurants from the response
    final List<Restaurant> restaurants = [];
    for (final restaurantData in (restaurantsResponse as List)) {
      final restaurantId = restaurantData['id'];
      final dishesResponse = await supabaseClient
          .from('dishes')
          .select()
          .eq('restaurant_id', restaurantId)
          .order('id');

      final dishes = <Dish>[];

      for (final dishData in dishesResponse as List) {
        final dish = Dish(
          restaurantId: dishData['restaurant_id'],
          name: dishData['name'],
          description: dishData['description'],
          price: dishData['price'],
          imgUrl: dishData['img_url'],
          popular: dishData['popular'],
        );

        dishes.add(dish);
      }

      final categoriesResponse = await supabaseClient
          .from('restaurant_categories')
          .select()
          .eq('restaurant_id', restaurantId)
          .order('id');

      final List<String> categories = [];

      for (final categoryData in categoriesResponse as List) {
        final String cat = categoryData['category'];

        categories.add(cat.trim());
      }

      // Constructing the Restaurant object
      final restaurant = Restaurant(
        id: restaurantId,
        name: restaurantData['name'],
        address: restaurantData['address'],
        description: restaurantData['description'],
        rating: restaurantData['rating'],
        priceLevel: restaurantData['price_level'],
        coverImg: restaurantData['cover_img'],
        openingHours: restaurantData['opening_hours'],
        homepage: restaurantData['homepage'],
        phone: restaurantData['phone'],
        dishes: dishes, // Add dishes here...
        categories: categories, // Add categories here...
        reviews: [],
        position: null,
      );

      restaurants.add(restaurant);
    }

    return restaurants;
  }

  Future<void> uploadRestaurantsToFirestore(
      List<Restaurant> restaurants) async {
    final CollectionReference restaurantCollection =
        firestore.collection('restaurants');

    // Iterate through the restaurants and add them to Firestore
    for (final restaurant in restaurants) {
      // Create a document reference for the new restaurant
      final DocumentReference restaurantDocRef =
          restaurantCollection.doc(restaurant.id);

      // Define the restaurant data
      final restaurantData = {
        'name': restaurant.name,
        'address': restaurant.address,
        'description': restaurant.description,
        'rating': restaurant.rating,
        'priceLevel': restaurant.priceLevel,
        'coverImg': restaurant.coverImg,
        'openingHours': restaurant.openingHours,
        'homepage': restaurant.homepage,
        'phone': restaurant.phone,
        'categories': restaurant.categories,
      };

      // Upload the restaurant data
      await restaurantDocRef.set(restaurantData);

      // Upload dishes to the restaurant's subcollection
      final CollectionReference dishesCollection =
          restaurantDocRef.collection('dishes');
      for (final dish in restaurant.dishes) {
        final dishData = {
          'restaurantId': dish.restaurantId,
          'name': dish.name,
          'description': dish.description,
          'price': dish.price,
          'img_url': dish.imgUrl,
          'popular': dish.popular,
        };

        await dishesCollection.add(dishData);
      }
    }
  }
}
