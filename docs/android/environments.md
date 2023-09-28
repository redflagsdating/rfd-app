# Environments

Android built-in support product flavor setting, so simply add `flavorDimensions` and `productFlavors` inside `android` section in the `android/app/build.gradle` file. See [Using flavors in Android](https://docs.flutter.dev/deployment/flavors#using-flavors-in-android).

```gradle
android {
    ...
    flavorDimensions += "env"
    productFlavors {
        dev {
            dimension "env"
            applicationIdSuffix ".dev"
            resValue "string", "app_name", "Red Flags Dev"
        }
        prod {
            dimension "env"
            resValue "string", "app_name", "Red Flags"
        }
    }
    ...
}
```

Also, update corresponding `google-services.json` files from **Firebase** console. See [Firebase environments](/docs/firebase/environments.md#google-servicesjson-and-googleservice-infoplist)

```yml
    .
    ├── android/        
    │   └── app/
    │       └── src/
    │           ├── dev/      
    │           │   └── google-services.json
    │           └── prod/      
    │               └── google-services.json
    │
    └── ...
```

See more details about *iOS*, *Firebase* and *Flutter* flavors.

- [Flutter flavors](/docs/flutter/environments.md)
- [Firebase environments](/docs/firebase/environments.md)
- [iOS product flavors](/docs/ios/environments.md)