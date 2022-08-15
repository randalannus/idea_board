import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:idea_board/model/user.dart';

class AuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static fb_auth.FirebaseAuth get _instance => fb_auth.FirebaseAuth.instance;

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
    fb_auth.OAuthCredential credential = fb_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    var userCredential = await _instance.signInWithCredential(credential);
    return SignInResult.fromUser(User.fromFirebaseAuth(userCredential.user!));
  }

  static Stream<User?> userChanges() {
    return _instance.userChanges().map((fbUser) {
      if (fbUser == null) return null;
      return User.fromFirebaseAuth(fbUser);
    });
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _instance.signOut();
  }

  static User? get currentUser {
    var fbUser = _instance.currentUser;
    if (fbUser == null) return null;
    return User.fromFirebaseAuth(fbUser);
  }

  static Future<void> useEmulator(String host, int port) async {
    await _instance.useAuthEmulator(host, 9099);
    await signOut();
  }
}

class SignInResult {
  final User? user;
  final SignInError? error;

  SignInResult.fromUser(this.user) : error = null;
  SignInResult.fromError(this.error) : user = null;

  bool get isSuccessful => user != null;
}

enum SignInError { failed, cancelled, noConnection }
