# Flutter cheat sheet

- [Detect build flavor/mode](#detect-build-flavormode)
- [Access package info](#access-package-info)
- [i18n & l10n](#i18n--l10n)
- [Show SnackBar](#show-snackbar)
- [Rename package name](#rename-package-name)
- [Logging](./logger.md#logging)

## Detect build flavor/mode

There are [two Firebase projects](/docs/firebase/environments.md), `rfd-app-dev` and `rfd-app-prod`, for `dev` and `prod` flavors respectively. Use `FlavorConfig` in the dart files to retrieve flavor's variables if you need conditional logic for two different flavors.

```dart
import 'package:flutter_flavor/flutter_flavor.dart';
...

FlavorConfig.instance.variables["longName"] == "Development" // 'Development' or 'Production'
```

Flutter ***"foundation"*** package gives us these build mode constants:

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
                // Access l10n message
                child: Text(AppLocalizations.of(context)!.signOut),
            ),
            )
        ],
        ),
    );
}
```

## Show SnackBar

`MixinSnackBar` is a wrapper of `SnackBar` that provides styled ***info, warning, error*** and ***success*** levels of SnackBar and show correspondent levels of SnackBar base on `AuthStatus`.

```dart
import 'package:red_flags/widgets/mixin_snack_bar.dart';

class PageSignInState extends State<PageSignIn> with MixinSnackBar {
    ...
    @override
    Widget build(BuildContext context) {
        return Scaffold(
        appBar: ...,
        body: TextButton(
            onPressed: isDisabled
                ? null
                : () {
                    // Show SnackBar base on AuthStatus
                    authProvider
                        .sendSignInLinkToEmail(textController.text)
                        .whenComplete(() =>
                            showAuthStatusSnackBar(context, authProvider));
                },
            child: Text(AppLocalizations.of(context)!.send),
        ),
        );
    }
}
```

## Rename package name

Follow the steps to rename app package name (or bundle ID) iff it is needed.

1. Run `change_app_package_name` command to rename

```bash
flutter pub run change_app_package_name:main com.redflags.app.dev
```

2. Go to **Firebase** console > ***Project settings*** > ***General*** > ***Your apps*** > ***Add app*** for both **iOS** and **Android** with the new package name. (e.g. `com.redfalgs.app.xxx`) Then copy the App settings over from the existing apps and remove the old apps.
3. Download `google-services.json` then update `android/app/src/dev/google-services.json` **OR** `android/app/src/prod/google-services.json` accordingly depends on the **Firebase** project belongs to.
4. Download `GoogleService-Info.plist` then update `ios/config/dev/GoogleService-Info.plist` **OR** `ios/config/prod/GoogleService-Info.plist` accordingly.
5. Run `flutterfire configure` to generate `lib/firebase_options.dart` then copy to `lib/firebase_options_dev.dart` **OR** `lib/firebase_options_prod.dart` accordingly.
6. [Update Google OAuth Web Client ID and secret](/docs/firebase/authentication.md#set-up-client-id).
7. Update `CFBundleURLSchemes` in `ios/config/Info-dev.plist` **OR** `ios/config/Info-prod.plist` Google Sign-In for **iOS**.
8. Search the old package name in **VSCode** under `lib/` to rename the reset of it.
