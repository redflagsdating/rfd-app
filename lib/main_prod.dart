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
  await dotenv.load(fileName: ".env");

  //** Flutter flavors */
  FlavorConfig(
    variables: {
      "longName": "Production",
      "bundleId": "com.redflags.app",
      "websiteUrl": "https://redflagsdating.com",
      "sumsubApiHost": "api.sumsub.com",
      "localStoragePrefix": "red.flags.",
      "firebaseAppName": "rfd-firebase-prod",
      "firebaseProjectId": "rfd-app-prod-1fdad",
      "firebaseStorageBucket": "rfd-app-prod-1fdad.appspot.com",
      "firebaseMessagingSenderId": "409120994021",
      "firebaseAndroidAppId": "1:409120994021:android:1462336e4c1b726eb25a0c",
      "firebaseAndroidClientId":
          "409120994021-fg81jk7ln7llfo2kiga8agdreu25j4r0.apps.googleusercontent.com",
      "firebaseIOSAppId": "1:409120994021:ios:e377d0c5298f975db25a0c",
      "firebaseIOSClientId":
          "409120994021-re50ugfvjqvrgnehkpq6pbbnamfglr2r.apps.googleusercontent.com",
    },
  );

  await initializeApp();
}
