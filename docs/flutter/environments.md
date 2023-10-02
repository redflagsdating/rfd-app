# Environments

There **two** environments, `dev` and `prod`, for development and build, it is called [flavor](https://docs.flutter.dev/deployment/flavors#what-are-flavors) in *Flutter* context. Flavor need to be configured accordingly for *Flutter*, *Firebase*, *iOS* and *Android* in order to map the flavors respectively. `flutter_flavor` Pub package is used to manage *Flutter* flavors specifically. See more details about native flavor and **Firebase** environments.

- [Firebase environments](/docs/firebase/environments.md)
- [iOS product flavors](/docs/ios/environments.md)
- [Android product flavors](/docs/android/environments.md)

`lib/main_dev.dart` and `lib/main_prod.dart` are two separated *Flutter* entry targets for running in different environments.

```yml
    .
    ├── lib/                
    │   ├── main_dev.dart                 
    │   └── main_prod.dart              
    └── ...
```

## Config env variables

Define env variables via `FlavorConfig` in `lib/main_dev.dart` or `lib/main_prod.dart`.

```dart
//** Flutter flavors */
  FlavorConfig(
    name: "DEV",
    variables: {
      "longName": "Development",
    },
  );
```

then access it across the entire app in dart files via `FlavorConfig.instance.variables`

```dart
_logger.d("Flavor profile: ${FlavorConfig.instance.variables["longName"]}");
```

## Run app in env

Follow the [Run](/README.md#run) guide to launch app in a specific environment.

`.vscode/launch.json` has been defined launch shortcut for different envs

```json
...
{
    "name": "DEV-Debug",
    "program": "lib/main_dev.dart",
    "request": "launch",
    "type": "dart",
    "args": [
        "--flavor",
        "dev"
    ]
},
{
    "name": "DEV-Profile",
    "program": "lib/main_dev.dart",
    "request": "launch",
    "type": "dart",
    "flutterMode": "profile",
    "args": [
        "--flavor",
        "dev"
    ]
},
...
```
so you can run via GUI

<img src="../vscode-run-debug.png" width="300px" />
