# Environments

There are **two** **Firebase** projects, `rfd-app-dev` and `rfd-app-prod`, for `dev` and `prod` flavors respectively. Select the right project when [sync Firebase configuration](/docs/firebase/cheat-sheet.md#sync-firebase-configuration) accordingly. See more details about native flavor and *Flutter* flavor.

- [Flutter flavors](/docs/flutter/environments.md)
- [iOS product flavors](/docs/ios/environments.md)
- [Android product flavors](/docs/android/environments.md)

Below are the **Firebase** related files for different environments.

```yml
    .
    ├── lib/                       
    │   ├── firebase_options.dart
    ├── android/        
    │   └── app/
    │       └── src/
    │           ├── dev/      
    │           │   └── google-services.json
    │           └── prod/      
    │               └── google-services.json
    ├── ios/        
    │   ├── config/
    │   │   ├── dev/      
    │   │   │   ├── firebase_app_id_file.json
    │   │   │   └── GoogleService-Info.plist
    │   │   └── prod/      
    │   │       ├── firebase_app_id_file.json
    │   │       └── GoogleService-Info.plist
    │   └── Runner/
    │       ├── Info-dev.plist
    │       └── Info-prod.plist
    │
    └── ...
```

## `firebase_options.dart`

`firebase_options.dart` is generated from Firebase CLI [Sync Firebase Configuration](/docs/firebase/cheat-sheet.md#sync-firebase-configuration). They are using to initialize *Firebase* service in `lib/main_dev.dart` and `lib/main_prod.dart`.

## `google-services.json` and `GoogleService-Info.plist`

Download it from `rfd-app-dev` and `rfd-app-prod` projects via **Firebase** console and update accordingly.

## `firebase_app_id_file.json`

Run `flutterfire configure` and select the project to generate accordingly.

## `Info-{flavor}.plist`

Only update **Firebase** specific fields accordingly such as `GIDClientID`, `FirebaseDynamicLinksCustomDomains` and etc.