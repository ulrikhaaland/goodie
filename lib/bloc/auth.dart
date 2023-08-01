import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get user => _auth.currentUser;

  String? verificationId;

  // Trigger phone number verification
  Future<void> verifyPhoneNumber(String phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        notifyListeners();
      },
      verificationFailed: (FirebaseAuthException e) {
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
    final credential = PhoneAuthProvider.credential(
        verificationId: verificationId!, smsCode: smsCode);
    await _auth.signInWithCredential(credential);
    notifyListeners();
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}
