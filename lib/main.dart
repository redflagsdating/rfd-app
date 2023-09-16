import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'firebase_options.dart';

void main() async {
  ///** Flutter ensure binding  */
  /// Ensure binding is initialized mainly for Firebase.initializeApp() can be
  /// executed before runApp()
  WidgetsFlutterBinding.ensureInitialized();

  ///** Firebase init */
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  ///** Firebase Crashlytics init */
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
  SharedPreferences localStorage = await SharedPreferences.getInstance();

  runApp(App(localStorage: localStorage));
}
