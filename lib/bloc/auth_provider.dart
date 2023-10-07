import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:goodie/model/user.dart';

class AuthProvider with ChangeNotifier {
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;

  firebase.User? get firebaseUser => _auth.currentUser;

  User? user;

  String? verificationId;

  // Trigger phone number verification
  Future<void> verifyPhoneNumber(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (firebase.PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        notifyListeners();
      },
      verificationFailed: (firebase.FirebaseAuthException e) {
        throw e;
        // Handle error
      },
      codeSent: (String verificationId, int? resendToken) {
        this.verificationId = verificationId;
        notifyListeners();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        this.verificationId = verificationId;
        notifyListeners();
      },
    );
  }

  // Trigger sign in with a verification code
  Future<void> signInWithVerificationCode(String smsCode) async {
    final credential = firebase.PhoneAuthProvider.credential(
        verificationId: verificationId!, smsCode: smsCode);
    await _auth.signInWithCredential(credential);
    user = User(firebaseUser: _auth.currentUser!, reviews: [], favorites: []);
    notifyListeners();
  }

  // Sign out
  Future<void> signOut() async {
    verificationId = null;
    await _auth.signOut();
    notifyListeners();
  }
}
