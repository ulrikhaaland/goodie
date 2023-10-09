import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:goodie/model/restaurant.dart';

class User {
  firebase.User? firebaseUser;
  List<RestaurantReview> reviews;
  List<String> favoriteReviews;
  List<String> favoriteRestaurants;
  bool isNewUser;
  String? fullName;
  String? username;

  User(
      {this.firebaseUser,
      this.fullName,
      this.username,
      required this.reviews,
      required this.favoriteReviews,
      required this.favoriteRestaurants,
      required this.isNewUser});
}
