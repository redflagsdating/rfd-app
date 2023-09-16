# Logging

- [Logger](#logger)
- [Firebase Crashlytics](/docs/firebase/crashlytics.md)

## Logger

`Logger` instance can be retrieved from `context` to start logging. It is provided by `LoggerProvider` that is a wrapper of [logger](https://pub.dev/packages/logger) Pub package and is initialized inside the `lib/app.dart` for the entire app.

```yml
.
└── lib                        
     └── services               
          └── logger_provider.dart    
```

Get the `Logger` instance from `context` in `.dart` files

```dart
final logger = Provider.of<LoggerProvider>(context).logger;
```

logging in different levels

```dart
logger.t("Trace log");
logger.d("Debug log");
logger.i("Info log");
logger.w("Warning log");
logger.e("Error log", error: 'Test Error');
logger.f("What a fatal log", error: error, stackTrace: stackTrace);
```

> Log with appropriate levels is crucial to ensure the best DX (Developer eXperience) to provide clear debugging info and prevent noise during development. This is also the key code review item.

***Important!!!***

When adding `try-catch` to log exceptions via `logger`, ensure the critical exceptions are `rethorw` to propagate for [Crashlytics](/docs/firebase/crashlytics.md) to catch and report in production build.
