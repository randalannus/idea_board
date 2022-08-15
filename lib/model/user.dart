import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

class User {
  final String uid;

  User(this.uid);

  User.fromFirebaseAuth(fb_auth.User fbUser) : uid = fbUser.uid;
}
