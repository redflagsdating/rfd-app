# Crashlytics

If you know **Sentry** then you know what **Crashlytics** does. It is initialized in `lib/main_dev.dart` and `lib/main_prod.dart` to report uncaught sync/async exceptions in ***Release*** build mode.

```dart
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
```
