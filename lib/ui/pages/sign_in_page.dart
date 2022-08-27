import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:idea_board/service/auth_service.dart';

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
              onPressed: _onGoogleSignInPressed,
            ),
            const SizedBox(
              height: 15,
            ),
            FutureBuilder<bool>(
              future: AuthService.appleSignInAvailable,
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!) {
                  return const SizedBox();
                }
                return SignInButton(
                  Buttons.Apple,
                  onPressed: _onAppleSignInPressed,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onGoogleSignInPressed() async {
    var result = await AuthService.signInWithGoogle(context);
    _respondToSignIn(result);
  }

  Future<void> _onAppleSignInPressed() async {
    var result = await AuthService.signInWithApple();
    _respondToSignIn(result);
  }

  void _respondToSignIn(SignInResult result) {
    if (result.isSuccessful) return;

    String? errorMessage;
    if (result.error! == SignInError.canceled) {
      errorMessage = "Sign in cancelled";
    } else if (result.error! == SignInError.noConnection) {
      errorMessage = "No internet connection";
    } else if (result.error! == SignInError.failed) {
      errorMessage = "Sign in failed";
    }

    if (mounted && errorMessage != null) {
      showSnackbar(context, errorMessage);
    }
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
