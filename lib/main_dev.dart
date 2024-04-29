import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:red_flags/main_init.dart';

void main() async {
  ///** Flutter ensure binding  */
  /// Ensure binding is initialized mainly for Firebase.initializeApp() can be
  /// executed before runApp()
  WidgetsFlutterBinding.ensureInitialized();

  //** Load secrets file */
  await dotenv.load(fileName: ".env.dev");

  //** Flutter flavors */
  FlavorConfig(
    name: "DEV",
    variables: {
      "longName": "Development",
      "displayName": "Red Flags Dating Development",
      "bundleId": "com.redflags.app.dev",
      "websiteUrl": "https://redflagsdating.com",
      "sumsubApiHost": "api.sumsub.com",
      "localStoragePrefix": "red.flags.dev.",
      "firebaseAppName": "rfd-firebase-dev",
      "firebaseProjectId": "rf-app-dev-7145f",
      "firebaseStorageBucket": "rf-app-dev-7145f.appspot.com",
      "firebaseMessagingSenderId": "775764266894",
      "firebaseAndroidAppId": "1:775764266894:android:3797c3595e512fdbb65edf",
      "firebaseAndroidClientId":
          "775764266894-h42irtjoedoeac0qh6a1p33l771l19i1.apps.googleusercontent.com",
      "firebaseIOSAppId": "1:775764266894:ios:263869f4f788811db65edf",
      "firebaseIOSClientId":
          "775764266894-13qbr357ueqb9kmntphvh66r9rec467q.apps.googleusercontent.com",
    },
  );

  await initializeApp();
}
