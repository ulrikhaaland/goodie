import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/user.dart';

Future<void> likeReview(String reviewId, User user) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Reference to the "likes" subcollection for the given review
  CollectionReference likesRef =
      firestore.collection('reviews').doc(reviewId).collection('likes');

  final userId = user.firebaseUser!.uid;

  user.favoriteReviews.add(reviewId);

  // Reference to the user's document in 'users' collection
  DocumentReference userRef = firestore.collection('users').doc(userId);

  // Run both adding a like and updating user favorites in a transaction
  await firestore.runTransaction((transaction) async {
    // Try to add the user's like
    transaction.set(likesRef.doc(userId), {'liked': true});

    // Add the review ID to the user's favorite reviews
    transaction.update(userRef, {
      'favoriteReviews': FieldValue.arrayUnion([reviewId])
    });
  }).catchError((error) {
    print("Failed to like review and update favorites: $error");
  });
}

Future<void> unlikeReview(String reviewId, User user) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Reference to the "likes" subcollection for the given review
  CollectionReference likesRef =
      firestore.collection('reviews').doc(reviewId).collection('likes');

  final userId = user.firebaseUser!.uid;

  user.favoriteReviews.remove(reviewId);

  // Reference to the user's document in 'users' collection
  DocumentReference userRef = firestore.collection('users').doc(userId);

  // Run both removing a like and updating user favorites in a transaction
  await firestore.runTransaction((transaction) async {
    // Try to remove the user's like
    transaction.delete(likesRef.doc(userId));

    // Remove the review ID from the user's favorite reviews
    transaction.update(userRef, {
      'favoriteReviews': FieldValue.arrayRemove([reviewId])
    });
  }).catchError((error) {
    print("Failed to unlike review and update favorites: $error");
  });
}

Future<void> bookmarkReview(String reviewId, User user) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Reference to the "bookmarks" subcollection for the given review
  CollectionReference bookmarksRef =
      firestore.collection('reviews').doc(reviewId).collection('bookmarks');

  final userId = user.firebaseUser!.uid;

  user.bookmarkedReviews.add(reviewId);

  // Reference to the user's document in 'users' collection
  DocumentReference userRef = firestore.collection('users').doc(userId);

  // Run both adding a bookmark and updating user bookmarks in a transaction
  await firestore.runTransaction((transaction) async {
    // Try to add the user's bookmark
    transaction.set(bookmarksRef.doc(userId), {'bookmarked': true});

    // Add the review ID to the user's bookmarked reviews
    transaction.update(userRef, {
      'bookmarkedReviews': FieldValue.arrayUnion([reviewId])
    });
  }).catchError((error) {
    print("Failed to bookmark review and update bookmarks: $error");
  });
}

Future<void> unbookmarkReview(String reviewId, User user) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Reference to the "bookmarks" subcollection for the given review
  CollectionReference bookmarksRef =
      firestore.collection('reviews').doc(reviewId).collection('bookmarks');

  final userId = user.firebaseUser!.uid;

  user.bookmarkedReviews.remove(reviewId);

  // Reference to the user's document in 'users' collection
  DocumentReference userRef = firestore.collection('users').doc(userId);

  // Run both removing a bookmark and updating user bookmarks in a transaction
  await firestore.runTransaction((transaction) async {
    // Try to remove the user's bookmark
    transaction.delete(bookmarksRef.doc(userId));

    // Remove the review ID from the user's bookmarked reviews
    transaction.update(userRef, {
      'bookmarkedReviews': FieldValue.arrayRemove([reviewId])
    });
  }).catchError((error) {
    print("Failed to unbookmark review and update bookmarks: $error");
  });
}
