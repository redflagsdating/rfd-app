# Flutter cheat sheet

- [Sync Firebase configuration](#sync-firebase-configuration)
- [Detect build modes](#detect-build-modes)
- [Logging](./logger.md#logging)
- [Access package info](#access-package-info)
- [i18n & l10n](#i18n--l10n)

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

## i18n & l10n

`l10n.yaml` is the config file

```yaml
arb-dir: lib/l10n  # App Resource Bundle folder 
template-arb-file: app_en.arb  # Default language App Resource Bundle file
output-localization-file: app_localizations.dart  # gen-10n output file
```

Define `localizationsDelegates` and `supportedLocales` in `app.dart` 

```dart
return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: const [Locale('en')],
```

Localized message in the language App Resource Bundle file, e.g. `app_en.arb`

```json
{
  "send": "Send",
  "signOut": "Sign out",
  "@signOut": {
    "description": "Sign out button text"
  }
}
```

Generate l10n files

```sh
flutter gen-l10n
```

Use the localized message in Widget

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

...

@override
Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
        children: <Widget>[
            Center(
            child: TextButton(
                onPressed: () async {
                await authProvider.handleSignOut();
                },
                // 
                child: Text(AppLocalizations.of(context)!.signOut),
            ),
            )
        ],
        ),
    );
}
```