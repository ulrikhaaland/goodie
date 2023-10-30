import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goodie/utils/image.dart';

import '../model/restaurant.dart';

class UserReviewProvider with ChangeNotifier {
  final ValueNotifier<List<RestaurantReview>> reviews = ValueNotifier([]);
  FirebaseStorage storage = FirebaseStorage.instance;

  final ValueNotifier<bool> soundOn = ValueNotifier(true);

  UserReviewProvider() {
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('reviews').get();
      List<Future<RestaurantReview>> futureReviews =
          querySnapshot.docs.map((doc) async {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final RestaurantReviewRating rating = RestaurantReviewRating(
          food: data['ratingFood'],
          service: data['ratingService'],
          price: data['ratingPrice'],
          atmosphere: data['ratingAtmosphere'],
          cleanliness: data['ratingCleanliness'],
          packaging: data['ratingPackaging'],
          overall: data['ratingOverall'],
        );

        return RestaurantReview(
          id: doc.id,
          restaurantId: data['restaurantId'],
          userId: data['userId'],
          dineIn: data['dineIn'],
          description: data['description'],
          rating: rating,
          timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
          media:
              await _handleMedia(data['images']), // Fetching images and videos
          // Add other fields like comments and likes here
        );
      }).toList();
      final localReviews =
          reviews.value.where((element) => element.isLocalReview).toList();

      final fetchedReviews = await Future.wait(futureReviews);

      // remove from local  reviews all reviews that has the same id as fetched reviews
      localReviews.removeWhere((localReview) => fetchedReviews
          .any((fetchedReview) => fetchedReview.id == localReview.id));

      // insert local reviews at the beginning of the list
      reviews.value = fetchedReviews
        ..sort(((a, b) => b.timestamp!.compareTo(a.timestamp!)))
        ..insertAll(0, localReviews);

      addImaginaryInteractions();
    } catch (e) {
      print("Failed to fetch reviews: $e");
    }
  }

  Future<List<MediaItem>> _handleMedia(data) async {
    List<MediaItem> media = [];
    if (data != null) {
      for (int i = 0; i < data.length; i++) {
        String url = data[i];
        MediaType mediaType =
            url.contains('mp4') ? MediaType.Video : MediaType.Image;
        if (mediaType == MediaType.Video) {
          // gs: //firebasestorage.googleapis.com/goodie-8814a.appspot.com/o/reviews/flamme-burger-frogner/1695907841164.mp4
          media.add(
            MediaItem(
                index: i,
                url: url,
                type: mediaType,
                ref: storage.refFromURL(url)),
          );
        } else {
          final ref = storage.refFromURL(url);
          // Assuming images don't need to fetch download URL and are already in gs:// format
          media.add(MediaItem(index: i, url: url, type: mediaType, ref: ref));
        }
      }
    }
    return media;
  }

  void addImaginaryInteractions() {
    Random random = Random();
    for (RestaurantReview review in reviews.value) {
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
      List<String> likes = [];
      for (int i = 0; i < likeCount; i++) {
        likes.add('likeId$i');
      }
      review.likes = likes;
    }
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
