import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<FirebaseApp> _initFirebase() async {
  return await Firebase.initializeApp(
    // Unique name is required to avoid using "Default" and clash with dev
    name: FlavorConfig.instance.variables["firebaseAppName"],
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

/// Required by FCM to have a top-level annotated background message handler.
/// Leave the empty function since app initialization is not needed and cause
/// exception when invoke _initFirebase().
@pragma('vm:entry-point')
Future<void> fcmBackgroundMessageHandler(RemoteMessage message) async {
  // await _initFirebase();
}

Future<void> initializeApp() async {
  //** Firebase init */
  await _initFirebase();

  //** Firestore database clear cached data from the previous sessions */
  await FirebaseFirestore.instance.clearPersistence();

  // ** App Check */
  await FirebaseAppCheck.instance.activate(
    androidProvider:
        kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.deviceCheck,
  );

  //** Crashlytics init (Release build only) */
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
  SharedPreferences.setPrefix(
    FlavorConfig.instance.variables["localStoragePrefix"],
  );
  SharedPreferences localStorage = await SharedPreferences.getInstance();

  //** Lock orientation to portrait */
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  //** Register FCM (Push Notification) background messages */
  FirebaseMessaging.onBackgroundMessage(fcmBackgroundMessageHandler);

  //** Run App */
  runApp(App(localStorage: localStorage));

  // final localNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // final androidNotificationChannel = AndroidNotificationChannel(
  //   "rfd-high-importance-channel",
  //   FlavorConfig.instance.variables["displayName"],
  //   description:
  //       "The high importance channel is to show notification when app is in foreground",
  //   importance: Importance.max,
  // );

  // await localNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(androidNotificationChannel);

  //** Register FCM (Push Notification) foreground message */
  // TODO: Revisit to show notification on Android foreground message, will need to figure out a proper way for l10n when using flutter_local_notification to show
  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   final notification = message.notification;
  //   final android = message.notification?.android;

  //   // If `onMessage` is triggered with a notification, construct our own
  //   // local notification to show to users using the created channel.
  //   if (notification != null && android != null) {
  //     localNotificationsPlugin.show(
  //       notification.hashCode,
  //       notification.titleLocKey,
  //       notification.bodyLocKey,
  //       NotificationDetails(
  //         android: AndroidNotificationDetails(
  //           androidNotificationChannel.id,
  //           androidNotificationChannel.name,
  //           channelDescription: androidNotificationChannel.description,
  //           icon: android.smallIcon,
  //           color: const Color(0xFFFF0041),
  //           // other properties...
  //         ),
  //       ),
  //       payload: json.encode(message.toMap()),
  //     );
  //   }
  // });

  // For iOS to show notifications when app in foreground
  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    sound: true,
    badge: true,
    alert: true,
  );
}
