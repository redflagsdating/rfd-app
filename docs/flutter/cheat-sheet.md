# Flutter cheat sheet

- [Sync Firebase configuration](#sync-firebase-configuration)
- [Detect build modes](#detect-build-modes)
- [Logging](./logger.md#logging)
- [Access package info](#access-package-info)

## Sync Firebase configuration

Whenever you change **Firebase** project settings or iOS/Android app settings you can run `flutterfire configure` command to sync and update your repo configuration files. Note that you will need to log in **Firebase CLI** first.

```bash
firebase login
```

then

```bash
flutterfire configure
```

## Detect build modes

Similar to `development` or `production` of `NODE_ENV` in `Node.js` world, Flutter ***"foundation"*** package gives us these build mode constants:

- `kDebugMode`
- `kReleaseMode`
- `kProfileMode`

Simply just import the package then you can start using it

```dart
import 'package:flutter/foundation.dart';

static const level = kDebugMode
      ? Level.debug
      : kReleaseMode
          ? Level.error
          : kProfileMode
              ? Level.fatal
              : Level.off;
```

## Access package info

Create a `PackageInfo` instance in the `.dart` file

```dart
final packageInfo = await PackageInfo.fromPlatform();
```

the `packageInfo` gives you access to **Android** and **iOS** package info

```dart
packageInfo.appName
packageInfo.packageName
packageInfo.buildNumber
packageInfo.version
...
```
