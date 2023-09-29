import 'package:flutter/material.dart';
import 'package:goodie/utils/image.dart';
import 'package:latlong2/latlong.dart';

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
  final List<String> categories;
  List<RestaurantReview> reviews;
  final LatLng? position;

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
      required this.reviews,
      required this.position});
}

class RestaurantReview {
  String? id;
  String restaurantId;
  String userId;
  String? description; //
  num? ratingFood; // 0-10 (needed for both dine in and takeout)
  num? ratingService; // 0-10 (needed only for dinein)
  num? ratingPrice; // 0-10 (needed for both dine in and takeout)
  num? ratingAtmosphere; // 0-10 (needed only for dinein)
  num? ratingCleanliness; // 0-10 (needed only for dinein)
  num? ratingPackaging; // 0-10 (needed only for takeout)
  num? ratingOverall; // 0-10 (needed for both dine in and takeout)
  DateTime? timestamp;
  bool dineIn; // If not dine-in, then takeout
  List<MediaItem>? media; // media of the review
  // Below are not for making a review, but for other users to interact with the review
  List<Comment>? comments; // Comments on the review
  List<Like>? likes; // Likes on the review

  RestaurantReview(
      {required this.restaurantId,
      required this.userId,
      required this.dineIn,
      this.media,
      this.ratingFood,
      this.ratingService,
      this.comments,
      this.likes,
      this.ratingPrice,
      this.ratingAtmosphere,
      this.ratingCleanliness,
      this.ratingPackaging,
      this.ratingOverall,
      this.id,
      this.description,
      this.timestamp});
}

class Comment {
  final String id;
  final String userId;
  final String userName;
  final String? userImgUrl;
  final String? description;
  final DateTime timestamp;

  Comment(
      {required this.id,
      required this.userId,
      required this.userName,
      required this.userImgUrl,
      required this.description,
      required this.timestamp});
}

class Like {
  final String id;
  final String userId;
  final String userName;
  final String? userImgUrl;
  final DateTime timestamp;

  Like(
      {required this.id,
      required this.userId,
      required this.userName,
      required this.userImgUrl,
      required this.timestamp});
}
