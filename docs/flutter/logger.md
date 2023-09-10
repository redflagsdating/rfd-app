# Logging

- [Logger](#logger)
- [Firebase Crashlytics](/docs/firebase/logging#crashlytics)

## Logger

The `LoggerProvider` is initialized in the `lib/app.dart` and start logging by retrieving the `Logger` instance from `context`. `LoggerProvider` is a wrapper of [logger](https://pub.dev/packages/logger) Pub package.

```yml
    .
    └── lib                        
         └── services               
              └── logger_provider.dart    
```

Retrieve the `Logger` instance from `context`

```dart
final logger = Provider.of<LoggerProvider>(context).logger;
```

start logging in different levels

```dart
logger.t("Trace log");
logger.d("Debug log");
logger.i("Info log");
logger.w("Warning log");
logger.e("Error log", error: 'Test Error');
logger.f("What a fatal log", error: error, stackTrace: stackTrace);
```
