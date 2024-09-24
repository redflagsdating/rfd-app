import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/user_provider.dart';

enum GeolocatorError {
  disabled,
  rejected,
  denied,
}

mixin MixinPermissions<T extends StatefulWidget> on State<T> {
  /// Prompt the user for location permissions.
  Future<bool> requestLocationPermissions() async {
    LocationPermission permission;

    if (!await Geolocator.isLocationServiceEnabled()) {
      return Future.error(GeolocatorError.disabled);
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Attempt to request permissions when it is currently not allowed
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error(GeolocatorError.rejected);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(GeolocatorError.denied);
    }

    return true;
  }

  /// Prompt the user for notification permissions by calling
  /// `FirebaseMessaging.instance.requestPermission()` which is similar to
  /// `Permission.notification.request()` from `permission_handler`.
  /// If [androidSdkInt] <= 33 (Android Version <= 12) it is auto-granted, so
  /// you won't see the request permissions prompt at all.
  Future<NotificationSettings> requestNotificationPermissions() async {
    final fcm = FirebaseMessaging.instance;
    final theme = Theme.of(context);
    final userProvider = context.read<UserProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);

    NotificationSettings settings = await fcm.getNotificationSettings();

    // Prompt to ask user's permission for push notification.
    // Set the permission requests to "provisional" which allows the user to
    // choose what type of notifications they would like to receive once the
    // user receives a notification.
    switch (settings.authorizationStatus) {
      case AuthorizationStatus.denied:
        scaffoldMessenger.showMaterialBanner(
          MaterialBanner(
            content: Text(
              l10n!.snackBarNotificationDenied(l10n.brandName),
            ),
            leading: Icon(
              Icons.notifications_off_sharp,
              color: theme.colorScheme.onSecondary,
            ),
            actions: [
              FilledButton.tonal(
                child: Text(l10n.settings),
                onPressed: () {
                  scaffoldMessenger.clearMaterialBanners();
                  AppSettings.openAppSettings(
                    type: AppSettingsType.notification,
                  );
                },
              ),
            ],
          ),
        );
        break;

      case AuthorizationStatus.notDetermined:
        settings = await fcm.requestPermission(provisional: true);
        continue updateToken;

      updateToken:
      default:
        final fcmToken = await fcm.getToken();

        if (fcmToken != null) {
          await userProvider.updateFcmToken(fcmToken);
        }
    }

    return settings;
  }
}
