import 'package:flutter/material.dart';
import 'package:goodie/bloc/create_review_provider.dart';
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
  //TODO: Create address object with city, country etc
  final String? address;
  // final String? city;
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

class RestaurantReviewRating {
  num? food; // 0-10 (needed for both dine in and takeout)
  num? service; // 0-10 (needed only for dinein)
  num? price; // 0-10 (needed for both dine in and takeout)
  num? atmosphere; // 0-10 (needed only for dinein)
  num? cleanliness; // 0-10 (needed only for dinein)
  num? packaging; // 0-10 (needed only for takeout)
  num? overall; // 0-10 (needed for both dine in and takeout)

  RestaurantReviewRating(
      {this.food,
      this.service,
      this.price,
      this.atmosphere,
      this.cleanliness,
      this.packaging,
      this.overall});
}

class RestaurantReview {
  String? id;
  String restaurantId;
  String userId;
  String? userName;
  String? description; //
  final RestaurantReviewRating rating;
  DateTime? timestamp;
  bool dineIn; // If not dine-in, then takeout
  List<MediaItem>? media; // network media of the review (images and videos)
  // used for local images, i.e showing the review that has just been made
  List<GoodieAsset>?
      assets; // media of the review  // Below are not for making a review, but for other users to interact with the review
  List<Comment>? comments; // Comments on the review
  List<String>? likes; // Likes on the review
  // used for local images, i.e showing the review that has just been made
  bool isLocalReview = false;

  RestaurantReview(
      {required this.restaurantId,
      required this.userId,
      required this.dineIn,
      required this.rating,
      this.media,
      this.comments,
      this.likes,
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

// class Like {
//   final String id;
//   final String userId;
//   final String userName;
//   final String? userImgUrl;
//   final DateTime timestamp;

//   Like(
//       {required this.id,
//       required this.userId,
//       required this.userName,
//       required this.userImgUrl,
//       required this.timestamp});
// }
