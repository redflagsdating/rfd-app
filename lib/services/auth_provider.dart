import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:red_flags/models/user.dart' show UserModel;
import 'package:red_flags/services/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// * Use `SocialAuthProvider.google` as an general identifier.
/// * Use `SocialAuthProvider.google.providerId` to compare against `providerData`
enum SocialAuthProvider {
  email('password'), // Email link (passwordless)
  google('google.com'),
  facebook('facebook.com');

  final String providerId;
  const SocialAuthProvider(this.providerId);
}

enum AuthStatus {
  pending,
  uninitialized,
  initializing,
  authenticated,
  authenticating,
  authenticateError,
  authenticateCanceled,
}

/// AuthProvider can be retrieved anywhere if you have access to the `context`
/// e.g. `AuthProvider authProvider = Provider.of<AuthProvider>(context);`
class AuthProvider extends ChangeNotifier {
  // Required parameters for testability in order to init instance externally
  // so we can init mock/fake instance for testing.
  AuthProvider({
    required this.logger,
    required this.gSignIn,
    required this.firebaseAuth,
    required this.localStorage,
    required this.userProvider,

    // Optional due to no mock/fake flutter_facebook_auth
    this.fbSignIn,
  }) {
    _authSubscription = firebaseAuth.authStateChanges().listen(
      (user) {
        logger.d(
          'Firebase Authentication listener uid=${user?.uid}, email=${user?.email}',
          time: DateTime.now(),
        );

        if (user == null && _status == AuthStatus.authenticated) {
          logger.w(
            'Null user with authenticated status, invoke handleSignOut()',
            time: DateTime.now(),
          );

          handleSignOut();
        }
      },
    );

    // Init status and check if user has signed in already
    isSignedIn().then(
      (isTrue) {
        if (isTrue) {
          _status = AuthStatus.authenticated;
          notifyListeners();
        }
      },
    );
  }

  final Logger logger;
  final GoogleSignIn gSignIn;
  final FacebookAuth? fbSignIn;
  final FirebaseAuth firebaseAuth;
  final SharedPreferences localStorage;
  final UserProvider userProvider;

  final isDev = FlavorConfig.instance.variables["longName"] == "Development";

  String? _code;
  String _message = '';
  AuthStatus _status = AuthStatus.uninitialized;
  late StreamSubscription _authSubscription;

  String? get code => _code;
  String get message => _message;
  AuthStatus get status => _status;

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  bool isUninitialized() {
    return _status == AuthStatus.uninitialized;
  }

  bool isInitializing() {
    return _status == AuthStatus.initializing;
  }

  bool isPending() {
    return _status == AuthStatus.pending;
  }

  bool isAuthenticated() {
    return _status == AuthStatus.authenticated;
  }

  bool isAuthenticating() {
    return _status == AuthStatus.authenticating;
  }

  bool isAuthCanceled() {
    return _status == AuthStatus.authenticateCanceled;
  }

  bool isAuthError() {
    return _status == AuthStatus.authenticateError;
  }

  /// A simple wrapper of `FirebaseAuth.instance.signInWithCredential` to handle errors.
  Future<UserCredential?> _signInWithCredential(
      AuthCredential credential) async {
    try {
      return await firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      await _onErrorOrException(e);
    }
    return null;
  }

  /// Widget requires to call `sendSignInLinkToEmail(email)` first to send an
  /// email with `emailLink` then Widget need to catch `emailLink` inside
  /// `didChangeAppLifecycleState` then call this function.
  ///
  /// The function default reads the current sign-in email address from
  /// **SharedPreferences** and call `FirebaseAuth.instance.signInWithEmailLink`
  /// along with the `emailLink` to get `UserCredential`.
  Future<UserCredential?> _signInWithEmailLink(String emailLink) async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      final email = await userProvider.getEmail();

      if (email != null) {
        return await firebaseAuth.signInWithEmailLink(
          email: email,
          emailLink: emailLink,
        );
      }
    } catch (e) {
      _onErrorOrException(e);
    }

    return null;
  }

  /// **Note:** `_signInWithFacebook` with a **Gmail** provider will be silently
  /// overwrite if `_signInWithGoogle` again with the same email address.
  Future<UserCredential?> _signInWithGoogle() async {
    GoogleSignInAccount? gUser;

    try {
      gUser = await gSignIn.signIn();

      if (gUser == null) {
        logger.w('Google sign-in is cancelled', time: DateTime.now());

        _status = AuthStatus.authenticateCanceled;
        notifyListeners();

        return null;
      }
    } catch (e) {
      /// All other exceptions will not be handled except kSignInCanceledError
      /// such as kNetworkError, kSignInFailedError and kSignInRequiredError.
      await _onErrorOrException(e);
      return null;
    }

    logger.d('Google sign-in success', time: DateTime.now());

    GoogleSignInAuthentication? gAuth = await gUser.authentication;
    logger.d(
      'Successfully extract Google signed-in user authentication',
      time: DateTime.now(),
    );

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );
    logger.d(
      'Successfully create credential from Google auth tokens',
      time: DateTime.now(),
    );

    _status = AuthStatus.authenticating;
    notifyListeners();

    return await _signInWithCredential(credential);
  }

  Future<UserCredential?> _signInWithFacebook() async {
    final LoginResult fbAuth = await fbSignIn!.login();

    switch (fbAuth.status) {
      case LoginStatus.cancelled:
        logger.w(
          'Facebook login cancelled with message: ${fbAuth.message}',
          time: DateTime.now(),
        );

        _status = AuthStatus.authenticateCanceled;
        notifyListeners();
        break;

      case LoginStatus.failed:
        await _onErrorOrException(fbAuth);
        break;

      case LoginStatus.operationInProgress:
        logger.d(
          'Facebook login operationInProgress with message: ${fbAuth.message}',
          time: DateTime.now(),
        );

        // TODO: Need to handle it?
        break;

      case LoginStatus.success:
        logger.d('Facebook login success', time: DateTime.now());

        final accessToken = fbAuth.accessToken;

        if (accessToken != null) {
          final OAuthCredential credential =
              FacebookAuthProvider.credential(accessToken.token);

          logger.d(
            'Successfully create credential from Facebook accessToken',
            time: DateTime.now(),
          );

          _status = AuthStatus.authenticating;
          notifyListeners();

          return _signInWithCredential(credential);
        }

        logger.e(
          'Facebook login success with NULL accessToken',
          time: DateTime.now(),
        );

        _message = 'Null auth credential from Facebook';
        _status = AuthStatus.authenticateError;
        notifyListeners();
        break;
    }

    return null;
  }

  /// * `logger`
  /// * Handle **FirebaseAuthException** `account-exists-with-different-credential`
  /// * Update error `code`, `message` and `status`
  Future<void> _onErrorOrException(dynamic e) async {
    logger.e(e, time: DateTime.now());

    _code = e.code;
    _message = e.message ?? '';

    // An existing account has been signed in with a different auth provider
    if (_code == 'account-exists-with-different-credential') {
      final email = (e as FirebaseAuthException).email;

      if (email != null) {
        final providers = await firebaseAuth.fetchSignInMethodsForEmail(email);

        _message =
            '$_message We have detected that your last signed in with ${providers.first}.';
      }
    }

    _status = AuthStatus.authenticateError;
    notifyListeners();
  }

  /// Cross user sign-in status **FirebaseAuth** `currentUser`, user data
  /// in **SharedPreferences** and `SocialAuthProvider` status
  Future<bool> isSignedIn() async {
    final uid = await userProvider.getId();
    final email = await userProvider.getEmail();
    final providerData = firebaseAuth.currentUser?.providerData;

    if (email == null ||
        providerData == null ||
        uid != firebaseAuth.currentUser!.uid) {
      logger.d('email: $email, providerData: $providerData',
          time: DateTime.now());

      return false;
    }

    _status = AuthStatus.authenticating;
    notifyListeners();

    UserInfo? userInfo;

    // Use for-in to iterate to allow `await` condition and break loop
    for (int i = 0; i < providerData.length; i++) {
      final element = providerData[i];

      if (element.email == email) {
        // Google Sign-in status
        if (element.providerId == SocialAuthProvider.google.providerId) {
          final gSignedIn = await gSignIn.isSignedIn();

          logger.d('gSignedIn: $gSignedIn', time: DateTime.now());

          if (gSignedIn) {
            userInfo = element;
            break;
          }
        }

        // Facebook Sign-in status
        if (element.providerId == SocialAuthProvider.facebook.providerId) {
          final fbSignedIn = (await fbSignIn!.accessToken) != null;
          final fbUserData =
              fbSignedIn ? await fbSignIn!.getUserData(fields: 'email') : null;

          logger.d(
            'fbSignedIn: $fbSignedIn, fbUserEmail: ${fbUserData?['email']}',
            time: DateTime.now(),
          );

          if (fbSignedIn && fbUserData?['email'] == email) {
            userInfo = element;
            break;
          }
        }

        // Email link sign-in
        if (element.providerId == SocialAuthProvider.email.providerId) {
          userInfo = element;
          break;
        }
      }
    }

    logger.d(
      'Signed-in with "${userInfo?.providerId}" of ${providerData.length} providers',
      time: DateTime.now(),
    );

    if (userInfo != null) {
      final user = await userProvider.getUserById(uid);

      // Update cache user data from database to keep it up-to-date
      if (user.docs.isNotEmpty) {
        userProvider.updateUserCache(user.docs.first.data());
      }

      return true;
    } else {
      return false;
    }
  }

  ///
  Future<void> sendSignInLinkToEmail(String email) async {
    _status = AuthStatus.initializing;
    notifyListeners();

    final packageInfo = await PackageInfo.fromPlatform();
    final dynamicLinkDomain =
        isDev ? 'redflagsdev.page.link' : 'redflagsprod.page.link';
    final url = 'https://$dynamicLinkDomain/${isDev ? 'iDzQ' : 'naxz'}';

    logger.d('Dynamic link url: $url', time: DateTime.now());

    try {
      await firebaseAuth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: ActionCodeSettings(
          url: url,
          handleCodeInApp: true,
          androidPackageName: packageInfo.packageName,
          iOSBundleId: packageInfo.packageName,
          dynamicLinkDomain: dynamicLinkDomain,
        ),
      );
      await userProvider.setEmail(email);

      _status = AuthStatus.pending;
      notifyListeners();
    } catch (e) {
      await _onErrorOrException(e);
    }
  }

  /// Sign-in handler function requires 'input' to indicate login methods,
  /// 'input' can be either：
  /// * `SocialAuthProvider`
  /// * String - Sign-in link in the email from `sendSignInLinkToEmail()`
  Future<bool> handleSignIn(dynamic input) async {
    late UserCredential? credential;

    final providerId = input is SocialAuthProvider ? input.providerId : null;
    final emailLink = input is! SocialAuthProvider ? input : '';

    logger.d(
      'Sign in with ${providerId ?? (emailLink != null ? 'emailLink' : '')}',
      time: DateTime.now(),
    );

    _code = null;
    _message = '';

    _status = AuthStatus.initializing;
    notifyListeners();

    if (providerId == SocialAuthProvider.google.providerId) {
      credential = await _signInWithGoogle();
    } else if (providerId == SocialAuthProvider.facebook.providerId) {
      credential = await _signInWithFacebook();
    } else if (emailLink.isNotEmpty) {
      credential = await _signInWithEmailLink(emailLink);
    }

    User? firebaseUser = credential?.user;

    logger.d('Extracted Firebase User from credential', time: DateTime.now());

    if (firebaseUser == null) {
      logger.d(
        'Firebase UserCredential contains NULL user',
        time: DateTime.now(),
      );

      return false;
    }

    await localStorage.setString(
      "providerId",
      providerId ?? SocialAuthProvider.email.providerId,
    );

    // Check the user existence in Firestore
    final user = await userProvider.getUserById(firebaseUser.uid);

    logger.d('Successfully query user in Firestore', time: DateTime.now());

    if (user.docs.isEmpty) {
      logger.d('New user logged in', time: DateTime.now());
      await userProvider.createUser(UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? "",
        createdAt: DateTime.now(),
        displayName: firebaseUser.displayName,
        phoneNumber: firebaseUser.phoneNumber,
        onboarded: false,
        verified: false,
        verifySubmitted: false,
      ));
    } else {
      logger.d('Existing user logged in', time: DateTime.now());
      await userProvider.updateUserCache(user.docs.first.data());
    }

    _status = AuthStatus.authenticated;
    notifyListeners();

    return true;
  }

  /// The main sign-out function relies on currentUser.providerData of Firebase
  /// Authentication to invoke corresponding provider's sing-out func.
  Future<void> handleSignOut() async {
    final providerId = firebaseAuth.currentUser?.providerData.first.providerId;

    /// Update status first to prevent incorrect status when authStateChanges
    /// is triggered after firebaseAuth.signOut() success.
    _code = null;
    _message = '';
    _status = AuthStatus.uninitialized;

    if (providerId != null) {
      logger.d('Start sign out $providerId', time: DateTime.now());

      await firebaseAuth.signOut();

      logger.d('Firebase signed out successfully', time: DateTime.now());

      if (providerId == SocialAuthProvider.google.providerId) {
        await gSignIn.signOut();

        logger.d('Google signed out successfully', time: DateTime.now());
      } else if (providerId == SocialAuthProvider.facebook.providerId) {
        await fbSignIn!.logOut();

        logger.d('Facebook logged out successfully', time: DateTime.now());
      }
    }
    notifyListeners();

    // TODO: Revisit, delay to avoid content flickering
    Future.delayed(
        const Duration(milliseconds: 300), () => userProvider.purgeUserCache());
  }
}
