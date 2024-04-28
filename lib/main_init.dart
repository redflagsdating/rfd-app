import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

  //** Local Notification init */
  final localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await localNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('ic_notification'),
      iOS: DarwinInitializationSettings(),
    ),
  );

  // Nested function mainly to get localNotificationsPlugin instance
  Future<void> showNotification(RemoteMessage message) async {
    final notification = message.notification;

    if (notification != null) {
      await localNotificationsPlugin.show(
        0,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            FlavorConfig.instance.variables["bundleId"],
            'Red Flags Dating Notification Channel',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            color: const Color(0xFFFF0041),
          ),
          iOS: const DarwinNotificationDetails(
            presentSound: true,
            presentBanner: true,
            presentAlert: true,
            presentBadge: true,
            categoryIdentifier: 'plainCategory',
          ),
        ),
        payload: json.encode(message.toMap()),
      );
    }
  }

  @pragma('vm:entry-point')
  Future<void> fcmBackgroundHandler(RemoteMessage message) async {
    await showNotification(message);
  }

  //** Lock orientation to portrait */
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  //** Register FCM (Push Notification) background messages listener */
  FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);

  //** Run App */
  runApp(App(localStorage: localStorage));

  //** Register FCM (Push Notification) foreground message */
  FirebaseMessaging.onMessage.listen(showNotification);

  // For iOS only
  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    sound: true,
    badge: true,
    alert: true,
  );
}
