import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Sign in",
              style: theme.textTheme.headlineLarge!.copyWith(
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(
              height: 100,
            ),
            SignInButton(
              Buttons.Google,
              onPressed: () => signInWithGoogle(context),
            )
          ],
        ),
      ),
    );
  }

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    // Trigger the authentication flow
    GoogleSignInAccount? googleUser;
    String? errorMessage;
    try {
      googleUser = await GoogleSignIn().signIn();
    } on PlatformException catch (e) {
      if (e.code == GoogleSignIn.kSignInFailedError) {
        errorMessage = "Sign in failed";
      } else if (e.code == GoogleSignIn.kNetworkError) {
        errorMessage = "No internet connection";
      } else {
        rethrow;
      }
    }

    // If authentication is fails or is aborted
    if (googleUser == null) {
      if (mounted) showSnackbar(context, errorMessage ?? "Sign in cancelled");
      return null;
    }

    // Obtain the auth details from the request
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        dismissDirection: DismissDirection.horizontal,
        margin: const EdgeInsets.all(8),
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }
}
