import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:idea_board/service/auth_service.dart';
import 'package:idea_board/ui/widgets/confimation_dialog.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SafeArea(
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
              const SignInButtons(),
            ],
          ),
        ),
      ),
    );
  }
}

class SignInButtons extends StatefulWidget {
  const SignInButtons({super.key});

  @override
  State<SignInButtons> createState() => _SignInButtonsState();
}

class _SignInButtonsState extends State<SignInButtons> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SignInButton(
          Buttons.Google,
          onPressed: onGoogleSignInPressed,
        ),
        const SizedBox(height: 15),
        FutureBuilder<bool>(
          future: AuthService.appleSignInAvailable,
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!) return Container();
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SignInButton(
                  Buttons.Apple,
                  onPressed: onAppleSignInPressed,
                ),
                const SizedBox(height: 15),
              ],
            );
          },
        ),
        const SizedBox(height: 15),
        TextButton(
          onPressed: onNoSignInPressed,
          child: const Text("Continue without signing in"),
        )
      ],
    );
  }

  Future<void> onGoogleSignInPressed() async {
    var result = await AuthService.signInWithGoogle();
    respondToSignIn(result);
  }

  Future<void> onAppleSignInPressed() async {
    var result = await AuthService.signInWithApple();
    respondToSignIn(result);
  }

  Future<void> onNoSignInPressed() async {
    bool userAccepted = await showConfirmationDialog(
      context: context,
      dialog: const ConfirmationDialog(
        title: "Warning",
        content:
            "Your data won't be synced across devices and uninstalling the "
            "app results in losing all your data.",
        confirmButton: "Continue",
      ),
    );
    if (!userAccepted) return;
    var result = await AuthService.signInWithDeviceId();
    respondToSignIn(result);
  }

  void respondToSignIn(SignInResult result) {
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
      showSnackbar(errorMessage);
    }
  }

  void showSnackbar(String message) {
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
