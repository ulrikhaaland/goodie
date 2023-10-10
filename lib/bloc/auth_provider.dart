import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:goodie/model/user.dart';

class AuthProvider with ChangeNotifier {
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;

  firebase.User? get firebaseUser => _auth.currentUser;

  ValueNotifier<User?> user = ValueNotifier(null);

  ValueNotifier<String?> verificationId = ValueNotifier(null);

  AuthProvider() {
    _auth.authStateChanges().listen((firebase.User? firebaseUser) {
      if (firebaseUser != null) {
        _initUser();
      } else {
        user.value = null;
      }
    });
  }

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    final Completer<void> completer = Completer<void>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (firebase.PhoneAuthCredential credential) async {
        try {
          await _auth.signInWithCredential(credential);
          completer.complete();
        } catch (e) {
          completer.completeError(e);
        }
      },
      verificationFailed: (firebase.FirebaseAuthException e) {
        completer.completeError(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        this.verificationId.value = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        this.verificationId.value = verificationId;
      },
    );

    return completer.future;
  }

  // Trigger sign in with a verification code
  Future<void> signInWithVerificationCode(String smsCode) async {
    final credential = firebase.PhoneAuthProvider.credential(
        verificationId: verificationId.value!, smsCode: smsCode);
    await _auth.signInWithCredential(credential);
    _initUser();
  }

  // Sign out
  Future<void> signOut() async {
    user.value = null;
    verificationId.value = null;
    await _auth.signOut();
  }

  void _initUser() async {
    if (firebaseUser == null) return;

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String userId =
        firebaseUser!.uid; // Make sure firebaseUser is not null

    DocumentSnapshot docSnap =
        await firestore.collection('users').doc(userId).get();

    if (docSnap.exists) {
      // Initialize from Firestore document
      Map<String, dynamic> data = docSnap.data() as Map<String, dynamic>;
      user.value = User(
          firebaseUser: firebaseUser,
          reviews: data['reviews'] ?? [],
          bookmarkedRestaurants: data['bookmarkedRestaurants'] ?? [],
          bookmarkedReviews: data['bookmarkedReviews'] != null
              ? (data['bookmarkedReviews'] as List).cast<String>()
              : [],
          favoriteReviews: data['favoriteReviews'] != null
              ? (data['favoriteReviews'] as List).cast<String>()
              : [],
          fullName: data['fullName'],
          username: data['username'],
          isNewUser: false);
    } else {
      // Initialize as you did before
      user.value = User(
          firebaseUser: firebaseUser,
          reviews: [],
          bookmarkedRestaurants: [],
          favoriteReviews: [],
          bookmarkedReviews: [],
          isNewUser: true);
    }
  }

  Future<void> updateUserData() async {
    final String userId =
        firebaseUser!.uid; // Make sure firebaseUser is not null
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final User updatedUser = user.value!; // Make sure user is not null

    try {
      await firestore.collection('users').doc(userId).set(
          {
            // 'reviews': updatedUser.reviews
            //     .map((review) => review.toJson())
            //     .toList(), // Replace with your logic to serialize
            'bookmarkedReviews': updatedUser.bookmarkedReviews
                .map((bookmarkedReview) => bookmarkedReview)
                .toList(),
            'favoriteReviews': updatedUser.favoriteReviews
                .map((favoriteReview) => favoriteReview)
                .toList(),
            'isNewUser': updatedUser.isNewUser,
            'fullName': updatedUser.fullName,
            'username': updatedUser.username,
          },
          SetOptions(
              merge:
                  true)); // Using SetOptions(merge: true) to only update fields that are passed

      user.value = updatedUser; // Optionally update the local user value
      notifyListeners(); // Notify listeners to rebuild UI if needed
    } catch (e) {
      print("Error updating user: $e");
      throw e; // Rethrow to handle it from where the function is called
    }
  }
}
