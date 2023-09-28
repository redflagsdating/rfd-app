import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'firebase_options_dev.dart';

void main() async {
  ///** Flutter ensure binding  */
  /// Ensure binding is initialized mainly for Firebase.initializeApp() can be
  /// executed before runApp()
  WidgetsFlutterBinding.ensureInitialized();

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

  //** Firebase init */
  await Firebase.initializeApp(
    // Unique name is required to avoid using "Default" and clash with prod
    name: 'rfd-firebase-dev',
    options: FirebaseOptionsDev.currentPlatform,
  );

  ///** Persistent storage init */
  /// a.k.a localStorage in JS world.
  /// (NSUserDefaults on iOS and macOS, SharedPreferences on Android, etc.)
  SharedPreferences.setPrefix("red.flags.dev");
  SharedPreferences localStorage = await SharedPreferences.getInstance();

  //** Flutter flavors */
  FlavorConfig(
    name: "DEV",
    variables: {
      "longName": "Development",
    },
  );

  runApp(App(localStorage: localStorage));
}
