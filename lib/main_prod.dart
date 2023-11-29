import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'firebase_options.dart';

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

  //** Firebase init */
  await Firebase.initializeApp(
    // Unique name is required to avoid using "Default" and clash with dev
    name: 'rfd-firebase-prod',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //** Firebase Crashlytics init for release mode only */
  if (kReleaseMode) {
    final crashlytics = FirebaseCrashlytics.instance;

    // Uncaught "fatal" errors
    FlutterError.onError = crashlytics.recordFlutterFatalError;

    // Uncaught asynchronous errors
    PlatformDispatcher.instance.onError = (error, stack) {
      crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  //** Persistent storage init */
  /// a.k.a localStorage in JS world.
  /// (NSUserDefaults on iOS and macOS, SharedPreferences on Android, etc.)
  SharedPreferences.setPrefix("red.flags.");
  SharedPreferences localStorage = await SharedPreferences.getInstance();

  // Lock orientation to portrait
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (_) => runApp(App(localStorage: localStorage)),
  );
}
