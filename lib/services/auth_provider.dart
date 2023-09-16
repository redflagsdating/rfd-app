import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:red_flags/models/user.dart';
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
  authenticated,
  authenticating,
  authenticateError,
  authenticateCanceled,
}

/// AuthProvider can be retrieved anywhere if you have access to the `context`
/// e.g. `AuthProvider authProvider = Provider.of<AuthProvider>(context);`
class AuthProvider extends ChangeNotifier {
  final Logger logger;
  final FirebaseFirestore firestore;
  final SharedPreferences localStorage;

  final gSignIn = GoogleSignIn();
  final fbSignIn = FacebookAuth.instance;
  final firebaseAuth = FirebaseAuth.instance;
  // TODO: Update production dynamic link domain
  final dynamicLinkDomain = kDebugMode ? 'redflagsdating.page.link' : '';

  String? _code;
  String _message = '';
  AuthStatus _status = AuthStatus.uninitialized;
  late StreamSubscription _authSubscription;

  String? get code => _code;
  String get message => _message;
  AuthStatus get status => _status;

  /// Constructor
  AuthProvider({
    required this.logger,
    required this.firestore,
    required this.localStorage,
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

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
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
    try {
      final email = localStorage.getString(UserFields.email.name);

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

        _message = 'You have cancelled sign in with Google.';
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

    return await _signInWithCredential(credential);
  }

  Future<UserCredential?> _signInWithFacebook() async {
    final LoginResult fbAuth = await fbSignIn.login();

    switch (fbAuth.status) {
      case LoginStatus.cancelled:
        logger.w(
          'Facebook login cancelled with message: ${fbAuth.message}',
          time: DateTime.now(),
        );

        _message = 'You have cancelled sign in with Facebook.';
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
    final email = localStorage.getString(UserFields.email.name);

    if (email == null) {
      logger.d('Email is NULL in SharedPreferences', time: DateTime.now());

      return false;
    }

    final gSignedIn = await gSignIn.isSignedIn();
    final fbSignedIn = (await fbSignIn.accessToken) != null;

    // Check assessToken to prevent exception from getUserData
    final fbUserData =
        fbSignedIn ? await fbSignIn.getUserData(fields: 'email') : null;

    logger.d(
      'gSignedIn: $gSignedIn, fbSignedIn: $fbSignedIn, fbUserEmail: ${fbUserData?['email']}',
      time: DateTime.now(),
    );
    final providerData = firebaseAuth.currentUser?.providerData;
    final userInfo = providerData?.firstWhere(
      (element) {
        if (element.email != email) {
          return false;
        }

        if (element.providerId == SocialAuthProvider.google.providerId) {
          return gSignedIn;
        }

        if (element.providerId == SocialAuthProvider.facebook.providerId) {
          return fbSignedIn && fbUserData?['email'] == email;
        }

        return element.providerId == SocialAuthProvider.email.providerId;
      },
    );

    logger.d(
      'Signed-in with "${userInfo?.providerId}" of ${providerData?.length} providers',
      time: DateTime.now(),
    );

    return userInfo != null;
  }

  ///
  Future<void> sendSignInLinkToEmail(String email) async {
    _status = AuthStatus.pending;
    notifyListeners();

    final packageInfo = await PackageInfo.fromPlatform();
    // TODO: Update production url path
    final url = 'https://$dynamicLinkDomain/${kDebugMode ? 'XktS' : ''}';

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

      //
      await localStorage.setString(UserFields.email.name, email);
    } catch (e) {
      await _onErrorOrException(e);
    }
  }

  /// Sign-in handler function requires 'input' to indicate login methods,
  /// 'input' can be either：
  /// * SocialAuthProvider
  /// * String - Sign-in link in the email from sendSignInLinkToEmail()
  Future<bool> handleSignIn(dynamic input) async {
    late UserModel userModel;
    late UserCredential? credential;

    final providerId = input is SocialAuthProvider ? input.providerId : null;
    final emailLink = input is! SocialAuthProvider ? input : '';

    logger.d(
      'Sign in with ${providerId ?? (emailLink != null ? 'emailLink' : '')}',
      time: DateTime.now(),
    );

    _code = null;
    _message = '';

    if (_status != AuthStatus.authenticating) {
      _status = AuthStatus.authenticating;
      notifyListeners();
    }

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

    // Check the user existence in Firestore
    final QuerySnapshot result = await firestore
        .collection(UserModel.collection)
        .where(UserFields.uid.name, isEqualTo: firebaseUser.uid)
        .get();
    final List<DocumentSnapshot> documents = result.docs;

    logger.d('Successfully query user in Firestore', time: DateTime.now());

    if (documents.isEmpty) {
      // New user
      logger.d('New user sing in', time: DateTime.now());

      userModel = UserModel.fromUser(firebaseUser);
      logger.d('Converted Firebase User to UserModel', time: DateTime.now());

      firestore
          .collection(UserModel.collection)
          .doc(firebaseUser.uid)
          .set(userModel.toJSON());

      logger.d('Saved user data to Firestore', time: DateTime.now());
    } else {
      // Existing user
      logger.d('Existing signed up user', time: DateTime.now());

      DocumentSnapshot docSnapshot = documents[0];
      userModel = UserModel.fromDocument(docSnapshot);

      logger.d(
        'Converted DocumentSnapshot into UserModel',
        time: DateTime.now(),
      );
    }

    // Save user data in the local storage
    await localStorage.setString(UserFields.uid.name, userModel.uid);
    await localStorage.setString(UserFields.email.name, userModel.email);
    await localStorage.setString(UserFields.photoUrl.name, userModel.photoUrl);
    await localStorage.setString(
        UserFields.phoneNumber.name, userModel.phoneNumber);
    await localStorage.setString(
        UserFields.displayName.name, userModel.displayName);

    logger.d(
      'Successfully write the user (${userModel.email}) into local storage',
      time: DateTime.now(),
    );

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
        await fbSignIn.logOut();

        logger.d('Facebook logged out successfully', time: DateTime.now());
      }
    }

    await localStorage.clear();

    logger.d('Local storage purged', time: DateTime.now());

    notifyListeners();
  }
}
