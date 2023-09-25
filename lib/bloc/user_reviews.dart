import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/restaurant.dart';

class UserReviewProvider with ChangeNotifier {
  List<RestaurantReview> reviews = [];

  UserReviewProvider() {
    fetchReviews();
    addImaginaryInteractions();
  }

  Future<void> fetchReviews() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('reviews').get();
      reviews = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return RestaurantReview(
          id: doc.id,
          restaurantId: data['restaurantId'],
          userId: data['userId'],
          dineIn: data['dineIn'],
          description: data['description'],
          ratingFood: data['ratingFood'],
          ratingService: data['ratingService'],
          ratingPrice: data['ratingPrice'],
          ratingAtmosphere: data['ratingAtmosphere'],
          ratingCleanliness: data['ratingCleanliness'],
          ratingPackaging: data['ratingPackaging'],
          ratingOverall: data['ratingOverall'],
          timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
          images: List<String>.from(data['images'] ?? []), // Fetching images
          // Add other fields like comments and likes here
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      print("Failed to fetch reviews: $e");
    }
  }

  void addImaginaryInteractions() {
    Random random = Random();
    for (RestaurantReview review in reviews) {
      // Generate imaginary comments
      int commentCount = random.nextInt(5); // Generate up to 5 comments
      List<Comment> comments = [];
      for (int i = 0; i < commentCount; i++) {
        comments.add(
          Comment(
            id: 'commentId$i',
            userId: 'userId$i',
            userName: 'User $i',
            userImgUrl: null,
            description: randomComments[random.nextInt(randomComments.length)],
            timestamp: DateTime.now(),
          ),
        );
      }
      review.comments = comments;

      // Generate imaginary likes
      int likeCount = random.nextInt(20); // Generate up to 20 likes
      List<Like> likes = [];
      for (int i = 0; i < likeCount; i++) {
        likes.add(
          Like(
            id: 'likeId$i',
            userId: 'userId$i',
            userName: 'User $i',
            userImgUrl: null,
            timestamp: DateTime.now(),
          ),
        );
      }
      review.likes = likes;
    }
    notifyListeners();
  }
}

const List<String> randomComments = [
  "Great place!",
  "I loved the food!",
  "Service could be better.",
  "Amazing atmosphere!",
  "Would definitely recommend!",
  "Not worth the price.",
  "Clean and well-maintained.",
  "Packaging was eco-friendly!",
  "Overall, a fantastic experience!",
  "I won't be coming back."
];
