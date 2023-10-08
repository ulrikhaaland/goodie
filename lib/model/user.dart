import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:goodie/model/restaurant.dart';

class User {
  firebase.User? firebaseUser;
  List<RestaurantReview> reviews;
  List<Restaurant> favorites;
  bool isNewUser;

  User(
      {this.firebaseUser,
      required this.reviews,
      required this.favorites,
      required this.isNewUser});
}
