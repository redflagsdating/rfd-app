# Firebase Authentication

- [AuthProvider](#authprovider)
- [Link accounts](#link-accounts)

## AuthProvider

`AuthProvider` is injected into the context in `lib/app.dart` for using across the entire app, check out `lib/services/auth_provider.dart` for technical details.

In order for `AuthProvider` to work on both Android and iOS, follow the guides below to set up your machine

- [Google Sign-In setup guide](#google-sign-in)
- [Facebook Sign-In setup guide](#facebook-sign-in)
- [Email Link Sign-In setup guide](#email-link-sign-in)

### Google Sign-In

- [Set up SHA1 key](#sha1-key) *(Android Only)*
- [Set up client id](#set-up-client-id) *(iOS Only)*

> See [Federated identity & social sign-in](https://firebase.google.com/docs/auth/flutter/federated-auth#google) doc for more insight

#### `SHA1 key`

You need to ensure your machine's **SHA1** key has been configured on Firebase for using Google Sign-In with Android. There are [few different ways](https://developers.google.com/android/guides/client-auth) to get the **SHA1** of your signing certificate and using **Gradle** `signingReport` command is the easiest way for development purpose.

Open the repository in **Android Studio**, click on ***Gradle*** tab on the top-right

<img src="./gradel-tab.png" width="150px" />

Click ***Execute Gradle Task*** icon

<img src="./execute-gradle-task.png" width="250px" />

Manually type in command `gradlew signingReport` then press *Enter* then you should see different variants of certificates are output on the console as below.

<img src="./gradlew-cmd.png" width="800px" />

Find the ***debug*** variant and copy the **SHA1**

```sh
Starting Gradle Daemon...
Gradle Daemon started in 1 s 481 ms

> Task :app:signingReport
Variant: debug
Config: debug
Store: /Users/brianliu/.android/debug.keystore
Alias: AndroidDebugKey
MD5: FE:AD:C8:13:18:F8:38:BC:B0:28:05:D4:58:28:9E:D7
SHA1: FB:D8:A5:06:4D:1F:B8:C0:5D:12:AD:B4:E3:47:F4:B1:FB:E5:82:5C
SHA-256: A4:B4:54:21:51:31:0A:E5:EC:36:27:95:1F:6D:CF:A1:9A:DB:9E:BF:32:BD:C4:A4:16:74:CD:1B:E1:11:1B:87
Valid until: Saturday, 26 July 2053
```

Go to **Firebase** console > ***Project settings*** > ***Add fingerprint*** then paste the **SHA1** key then save.

<img src="./firebase-project-settings-android.png" width="800px" />

#### `Set up client id`

You can run `flutterfire configure` command to automatically update all the configurations (see [Sync Firebase configuration](../flutter/cheat-sheet.md#sync-firebase-configuration)) and only follow the below steps to manually check if you have problems to run Google Sign-In on iOS devices.


Open `ios/Runner/GoogleService-Info.plist` file and go to [Firebase console](https://console.firebase.google.com/) > ***Project settings*** > ***iOS*** app.

Ensure `GOOGLE_APP_ID` and `BUNDLE_ID` in the `GoogleService-Info.plist` are matched with the `App ID` and `Bundle ID` respectively.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
...
<key>BUNDLE_ID</key>
<string>com.redflags.app</string>
...
<key>GOOGLE_APP_ID</key>
<string>1:775764266894:ios:f4e7ec7603147392b65edf</string>
</dict>
</plist>
```

<img src="./firebase-project-settings-ios.png" width="800px" />

Go to [GCP console](https://console.cloud.google.com/) > ***API and services*** > ***Credentials*** > ***OAuth 2.0 Client IDs*** > `iOS client for com.redflags.app (auto created by Google Service)`.

<img src="./gcp-oauth-client-ids.png" width="600px" />

Ensure `CLIENT_ID` and `REVERSED_CLIENT_ID` in the `GoogleService-Info.plist` are matched with the `Client ID` and `iOS URL scheme` respectively.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>CLIENT_ID</key>
<string>775764266894-5j0h326ek4l17u6pp9k1kn1vgov4dfsp.apps.googleusercontent.com</string>
<key>REVERSED_CLIENT_ID</key>
<string>com.googleusercontent.apps.775764266894-5j0h326ek4l17u6pp9k1kn1vgov4dfsp</string>
...
</dict>
</plist>
```

<img src="./gcp-oauth-ios-client-ids.png" width="600px" />

Open `ios/Runner/Info.plist` then copy and paste the below snippet and ensure `GIDClientID` and `CFBundleURLSchemes` are matched with the `Client ID` and `iOS URL scheme` respectively.

```xml
<!-- Google Sign-in Section -->
<key>GIDClientID</key>
<string>775764266894-5j0h326ek4l17u6pp9k1kn1vgov4dfsp.apps.googleusercontent.com</string>
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.775764266894-5j0h326ek4l17u6pp9k1kn1vgov4dfsp</string>
    </array>
  </dict>
</array>
<!-- End of the Google Sign-in Section -->
```

> Check out more details on [google_sign_in iOS integration](https://pub.dev/packages/google_sign_in#ios-integration).

### Facebook Sign-In

Install the `flutter_facebook_auth` plugin.

```sh
flutter pub add flutter_facebook_auth
```

- [iOS configuration](https://facebook.meedu.app/docs/5.x.x/ios)
- [Android configuration](https://facebook.meedu.app/docs/5.x.x/android/)

> (***Important***) If the same email address has been signed in with a different identify provider before, **Facebook** will return `LoginStatus.failed` with account already exists reason, vice versa.

> (***Important***) If user has been signed in with **Facebook** before and the **Facebook** account contains a **Gmail** email address, when sign in with the same **Gmail** via email link will [link the accounts](#link-accounts) together. However, when sign in with **Google** will overwrite the account provider because [Google is a trusted provider](https://groups.google.com/g/firebase-talk/c/ms_NVQem_Cw/m/8g7BFk1IAAAJ).

### Email Link Sign-In

Email link sign-in is a ***passwordless*** method by sending an authentication link to email then allow users to click the link to sign in app directly.

It has dependency with Firebase [Dynamic Links](https://firebase.google.com/docs/dynamic-links/flutter/receive) in order to achieve auto sign in flow *click email link -> in-app redirection -> receive link and create user auth*.

> (***Important***) Even though [Dynamic Link is deprecated](https://firebase.google.com/support/dynamic-links-faq) and will shut down on August 25, 2025, [email link authentication will continue to work](https://firebase.google.com/support/dynamic-links-faq#i_only_use_dynamic_links_for_firebase_authentication_will_email_link_authentication_in_firebase_authentication_continue_to_work) as an exclusion.

Setup guides:
- [Email link auth setup guide](https://firebase.google.com/docs/auth/flutter/email-link-auth)
- [Flutter receive Dynamic links](https://firebase.google.com/docs/dynamic-links/flutter/receive)

The flow starts with sending the auth link to an email

```dart
await authProvider.sendSignInLinkToEmail(email)
```

user then receive an email and click the link inside the email, user will be redirected back to the app. In order to receive the authentication data from the link, the `Widget` needs to extends `WidgetsBindingObserver` class and call `addObserver` in order to notify in `didChangeAppLifecycleState` function.

Inside `didChangeAppLifecycleState` lifecycle function create `FirebaseDynamicLinks` listener to catch the email link from the redirection then call `authProvider.handleSignIn(emailLink)` with the email link string to complete the authentication flow.

```dart
class SignInEmailPageState extends State<SignInEmailPage>
    with WidgetsBindingObserver {
  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    try {
      //
      final subscription = FirebaseDynamicLinks.instance.onLink.listen(
        (event) {
          if (authProvider.status == AuthStatus.pending) {
            authProvider.handleSignIn(event.link.toString()).then(
              (signedIn) {
                if (signedIn &&
                    authProvider.status == AuthStatus.authenticated) {
                  Navigator.popAndPushNamed(context, '/');
                }
              },
            );
          }
        },
      );

      if (authProvider.status == AuthStatus.authenticated) {
        subscription.cancel();
      }
    } catch (e) {
      //
    }
  }
```

## Link accounts

User account is **unique** and identified by **email address**, so when a user signs in using different identity providers (*Google*, *Facebook* or *Email Link*), the accounts will be linked and merged into one account.

<img src="./link-accounts.png" width="600px" />

For example as below, ralphbliu@gmail.com has been logged in both *Google* and *Email Link*, so the accounts are linked into one with multiple providers.

<img src="./link-accounts-example.png" width="600px" />