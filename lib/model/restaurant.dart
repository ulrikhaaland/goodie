class Dish {
  final String restaurantId;
  final String name;
  final String? description;
  final num price;
  final String? imgUrl;
  final bool popular;

  Dish(
      {required this.restaurantId,
      required this.name,
      required this.description,
      required this.price,
      required this.imgUrl,
      required this.popular});
}

class Restaurant {
  final String id;
  final String name;
  final String? address;
  final String? description;
  final num? rating;
  final int? priceLevel;
  final String? coverImg;
  final String? openingHours;
  final String? homepage;
  final String? phone;
  List<Dish> dishes;
  final Set<String> categories;
  List<RestaurantReview> reviews;

  Restaurant(
      {required this.id,
      required this.name,
      required this.address,
      required this.description,
      required this.rating,
      required this.priceLevel,
      required this.coverImg,
      required this.openingHours,
      required this.homepage,
      required this.phone,
      required this.dishes,
      required this.categories,
      required this.reviews});
}

class RestaurantReview {
  final String id;
  final String restaurantId;
  final String userId;
  final String userName;
  final String? userImgUrl;
  final String? review;
  final num? rating;
  final DateTime timestamp;

  RestaurantReview(
      {required this.id,
      required this.restaurantId,
      required this.userId,
      required this.userName,
      required this.userImgUrl,
      required this.review,
      required this.rating,
      required this.timestamp});
}
