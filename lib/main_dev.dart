import 'package:firebase_app_check/firebase_app_check.dart';
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
  await dotenv.load(fileName: ".env.dev");

  //** Flutter flavors */
  FlavorConfig(
    name: "DEV",
    variables: {
      "longName": "Development",
      "bundleId": "com.redflags.app.dev",
      "sumsubApiHost": "api.sumsub.com",
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

  //** Firebase init */
  await Firebase.initializeApp(
    // Unique name is required to avoid using "Default" and clash with prod
    name: 'rfd-firebase-dev',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ** Firebase App Check */
  await FirebaseAppCheck.instance.activate(
    androidProvider:
        kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
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

  ///** Persistent storage init */
  /// a.k.a localStorage in JS world.
  /// (NSUserDefaults on iOS and macOS, SharedPreferences on Android, etc.)
  SharedPreferences.setPrefix("red.flags.dev.");
  SharedPreferences localStorage = await SharedPreferences.getInstance();

  // Lock orientation to portrait
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (_) => runApp(App(localStorage: localStorage)),
  );
}
