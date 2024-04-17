# idea_board

An app for collecting your best ideas.

## Setting up firebase (relevant links)
Follow the first link to install Firebase CLI and FlutterFire CLI.
* [Add Firebase to your Flutter app](https://firebase.google.com/docs/flutter/setup)
* [Get Started with Firebase Authentication on Flutter](https://firebase.google.com/docs/auth/flutter/start)

Be sure to run the `flutterfire configure` command as described in the "Add Firebase to your Flutter app" guide.

You need to add your SHA1 key to firebase in order to use google sign-in.
https://stackoverflow.com/questions/51845559/generate-sha-1-for-flutter-react-native-android-native-app

Project: mind-boxes

## Setting up firebase emulator
If you have already installed firebase run `firebase emulators:start` in the project directory to start the emulators.

If you provide the argument `--dart-define=FIREBASE_EMULATOR_HOST=<your-emulator-device-ip>` to `flutter run`, then
debug builds will use the emulator. To find your device ip run `ipconfig` on windows and look for "ipv4 address".

Add `"args": ["--dart-define=FIREBASE_EMULATOR_HOST=<your-emulator-device-ip>"]` to your VS Code launch config to
provide the argument.

To give firebase functions access to Gemini, add the Google AI API key to `functions/.secret.local`.

# Running on iOS
Execute `pod update` in the ios folder before compiling for iOS to speed up the compiling process.
There is a line in `/ios/Podfile` that needs to be commented out for release builds. See the file for more info.
