# Environments

Android built-in support product flavor setting, so simply add `flavorDimensions` and `productFlavors` inside `android` section in the `android/app/build.gradle` file. See [Using flavors in Android](https://docs.flutter.dev/deployment/flavors#using-flavors-in-android).

```gradle
android {
    ...
    signingConfigs {
        debug {
            storeFile file('/Users/brianliu/.android/debug.keystore')
        }
        release {
        storeFile file('/Users/brianliu/.android/upload-keystore.jks')
            keyAlias 'upload'
            storePassword '2agijrdl'
            keyPassword '2agijrdl'
        }
    }
    flavorDimensions += "env"
    productFlavors {
        dev {
            dimension "env"
            applicationIdSuffix ".dev"
            resValue "string", "app_name", "Red Flags Dating Dev"
            resValue "string", "facebook_app_id", "6720461168002075"
            resValue "string", "facebook_client_token", "e352f70134fd3a3ecff44f34d4593862"
            resValue "string", "fb_login_protocol_scheme", "fb6720461168002075"
            signingConfig signingConfigs.debug
        }
        prod {
            dimension "env"
            resValue "string", "app_name", "Red Flags Dating"
            resValue "string", "facebook_app_id", "255952837340203"
            resValue "string", "facebook_client_token", "e393bca70fa3829bbe4ed3b942d29ac7"
            resValue "string", "fb_login_protocol_scheme", "fb255952837340203"
            signingConfig signingConfigs.release
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
