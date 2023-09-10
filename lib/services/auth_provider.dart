import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:red_flags/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [SocialAuthProvider] Supported social authentication providers with value
/// providerId from Firebase User model in order to check logged in user's provider
enum SocialAuthProvider {
  google('google.com'),
  facebook('facebook.com');

  final String providerId;

  const SocialAuthProvider(this.providerId);
}

enum AuthStatus {
  uninitialized,
  authenticated,
  authenticating,
  authenticateError,
  authenticateCanceled,
}

/// [AuthProvider]
class AuthProvider extends ChangeNotifier {
  final Logger logger;
  final FirebaseFirestore firestore;
  final SharedPreferences localStorage;

  final gSignIn = GoogleSignIn();
  final fbSignIn = FacebookAuth.instance;
  final firebaseAuth = FirebaseAuth.instance;

  String? _code;
  String _message = '';
  AuthStatus _status = AuthStatus.uninitialized;

  String? get code => _code;
  String get message => _message;
  AuthStatus get status => _status;

  /// Constructor
  AuthProvider({
    required this.logger,
    required this.firestore,
    required this.localStorage,
  }) {
    // Listen to Firebase Authentication status changes
    firebaseAuth.authStateChanges().listen(
      (user) {
        logger.d(
          '[constructor] Firebase Authentication listener uid=${user?.uid}, email=${user?.email}',
          time: DateTime.now(),
        );

        if (user == null && _status == AuthStatus.authenticated) {
          logger.w(
            '[constructor] Null user with authenticated status, invoke handleSignOut()',
            time: DateTime.now(),
          );

          handleSignOut();
        }
      },
    );
  }

  /// [_signInWithCredential]
  /// A simple wrapper of firebase_auth signInWithCredential function to handle
  /// errors.
  Future<UserCredential?> _signInWithCredential(
      AuthCredential credential) async {
    try {
      return await firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      await _onException(e);
    }

    return null;
  }

  /// [_signInWithGoogle]
  /// Private function to sign in with Google and generate credential to
  /// sign in Firebase user.
  Future<UserCredential?> _signInWithGoogle() async {
    GoogleSignInAccount? gUser;

    try {
      gUser = await gSignIn.signIn();

      if (gUser == null) {
        logger.w(
          '[_signInWithGoogle] Google sign-in is cancelled',
          time: DateTime.now(),
        );

        _message = 'You have cancelled sign in with Google.';
        _status = AuthStatus.authenticateCanceled;
        notifyListeners();

        return null;
      }
    } catch (e) {
      /// All other exceptions will not be handled except kSignInCanceledError
      /// such as kNetworkError, kSignInFailedError and kSignInRequiredError.
      await _onException(e);

      return null;
    }

    logger.d(
      '[_signInWithGoogle] Google sign-in success',
      time: DateTime.now(),
    );

    GoogleSignInAuthentication? gAuth = await gUser.authentication;
    logger.d(
      '[_signInWithGoogle] Successfully extract Google signed-in user authentication',
      time: DateTime.now(),
    );

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );
    logger.d(
      '[_signInWithGoogle] Successfully create credential from Google auth tokens',
      time: DateTime.now(),
    );

    return await _signInWithCredential(credential);
  }

  /// [_signInWithFacebook]
  /// Private function to sign in with Facebook and generate credential
  /// to sign in Firebase user.
  Future<UserCredential?> _signInWithFacebook() async {
    final LoginResult fbAuth = await fbSignIn.login();

    switch (fbAuth.status) {
      case LoginStatus.cancelled:
        logger.w(
          '[_signInWithFacebook] Facebook login cancelled with message: ${fbAuth.message}',
          time: DateTime.now(),
        );

        _message = 'You have cancelled sign in with Facebook.';
        _status = AuthStatus.authenticateCanceled;
        notifyListeners();
        break;

      case LoginStatus.failed:
        await _onException(fbAuth);
        break;

      case LoginStatus.operationInProgress:
        logger.d(
          '[_signInWithFacebook] Facebook login operationInProgress with message: ${fbAuth.message}',
          time: DateTime.now(),
        );

        // TODO: Need to handle it?
        break;

      case LoginStatus.success:
        logger.d(
          '[_signInWithFacebook] Facebook login success',
          time: DateTime.now(),
        );

        final accessToken = fbAuth.accessToken;

        if (accessToken != null) {
          final OAuthCredential credential =
              FacebookAuthProvider.credential(accessToken.token);

          logger.d(
            '[_signInWithFacebook] Successfully create credential from Facebook accessToken',
            time: DateTime.now(),
          );

          return _signInWithCredential(credential);
        }

        logger.e(
          '[_signInWithFacebook] Facebook login success with NULL accessToken',
          time: DateTime.now(),
        );

        _status = AuthStatus.authenticateError;
        notifyListeners();
        break;
    }

    return null;
  }

  /// [_onException]
  /// A simple function to update state on exceptions to avoid duplicate code
  Future<void> _onException(dynamic e) async {
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

  /// [handleSignIn]
  /// The main sign-in function requires specify auth provider
  Future<bool> handleSignIn(SocialAuthProvider provider) async {
    late UserModel userModel;
    late UserCredential? credential;

    logger.d(
      '[handleSignIn] Sign in with ${provider.providerId}',
      time: DateTime.now(),
    );

    _code = null;
    _message = '';
    _status = AuthStatus.authenticating;
    notifyListeners();

    switch (provider) {
      case SocialAuthProvider.google:
        credential = await _signInWithGoogle();
        break;

      case SocialAuthProvider.facebook:
        credential = await _signInWithFacebook();
        break;
    }

    User? firebaseUser = credential?.user;

    logger.d(
      '[handleSignIn] Extracted Firebase User from credential',
      time: DateTime.now(),
    );

    if (firebaseUser == null) {
      logger.d(
        '[handleSignIn] Firebase UserCredential contains NULL user',
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

    logger.d(
      '[handleSignIn] Successfully query user in Firestore',
      time: DateTime.now(),
    );

    if (documents.isEmpty) {
      // New user
      logger.d(
        '[handleSignIn] New user sing in',
        time: DateTime.now(),
      );

      userModel = UserModel.fromUser(firebaseUser);
      logger.d(
        '[handleSignIn] Converted Firebase User to UserModel',
        time: DateTime.now(),
      );

      firestore
          .collection(UserModel.collection)
          .doc(firebaseUser.uid)
          .set(userModel.toJSON());

      logger.d(
        '[handleSignIn] Saved user data to Firestore',
        time: DateTime.now(),
      );
    } else {
      // Existing user
      logger.d(
        '[handleSignIn] Existing signed up user',
        time: DateTime.now(),
      );

      DocumentSnapshot docSnapshot = documents[0];
      userModel = UserModel.fromDocument(docSnapshot);

      logger.d(
        '[handleSignIn] Converted DocumentSnapshot into UserModel',
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
      '[handleSignIn] Successfully write the user (${userModel.email}) into local storage',
      time: DateTime.now(),
    );

    _status = AuthStatus.authenticated;
    notifyListeners();

    return true;
  }

  /// [handleSignOut]
  /// The main sign-out function relies on currentUser.providerData of Firebase
  /// Authentication to invoke corresponding provider's sing-out func.
  Future<void> handleSignOut() async {
    final providerId = firebaseAuth.currentUser?.providerData[0].providerId;

    /// Update status first to prevent incorrect status when authStateChanges
    /// is triggered after firebaseAuth.signOut() success.
    _code = null;
    _message = '';
    _status = AuthStatus.uninitialized;

    if (providerId != null) {
      logger.d(
        '[handleSignOut] Start sign out $providerId',
        time: DateTime.now(),
      );

      await firebaseAuth.signOut();

      logger.d(
        '[handleSignOut] Firebase signed out successfully',
        time: DateTime.now(),
      );

      if (providerId == SocialAuthProvider.google.providerId) {
        await gSignIn.signOut();

        logger.d(
          '[handleSignOut] Google signed out successfully',
          time: DateTime.now(),
        );
      } else if (providerId == SocialAuthProvider.facebook.providerId) {
        await fbSignIn.logOut();

        logger.d(
          '[handleSignOut] Facebook logged out successfully',
          time: DateTime.now(),
        );
      }
    }

    await localStorage.clear();

    logger.d(
      '[handleSignOut] Local storage purged',
      time: DateTime.now(),
    );

    notifyListeners();
  }
}
