import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static Future<SignInResult> signInWithGoogle(BuildContext context) async {
    // Trigger the authentication flow
    GoogleSignInAccount? googleUser;
    try {
      googleUser = await _googleSignIn.signIn();
    } on PlatformException catch (e) {
      if (e.code == GoogleSignIn.kSignInFailedError) {
        return SignInResult.fromError(SignInError.failed);
      } else if (e.code == GoogleSignIn.kNetworkError) {
        return SignInResult.fromError(SignInError.noConnection);
      } else {
        rethrow;
      }
    }

    // If authentication fails or is aborted
    if (googleUser == null) {
      return SignInResult.fromError(SignInError.cancelled);
    }

    // Obtain the auth details from the request
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    var userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    return SignInResult.fromUserCredential(userCredential);
  }

  static Stream<User?> userChanges() {
    return FirebaseAuth.instance.userChanges();
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }

  static User? get currentUser => FirebaseAuth.instance.currentUser;

  static Future<void> useEmulator(String host, int port) async {
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    await signOut();
  }
}

class SignInResult {
  final UserCredential? userCredential;
  final SignInError? error;

  SignInResult.fromUserCredential(this.userCredential) : error = null;
  SignInResult.fromError(this.error) : userCredential = null;

  bool get isSuccessful => userCredential != null;
}

enum SignInError { failed, cancelled, noConnection }
