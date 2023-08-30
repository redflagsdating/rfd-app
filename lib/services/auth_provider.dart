import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:red_flags/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SignInProvider {
  google,
  facebook,
}

enum AuthStatus {
  uninitialized,
  authenticated,
  authenticating,
  authenticateError,
  authenticateException,
  authenticateCanceled,
}

///
class AuthProvider extends ChangeNotifier {
  final FirebaseFirestore firestore;
  final SharedPreferences localStorage;

  final gSignIn = GoogleSignIn();
  final fbSignIn = FacebookAuth.instance;
  final firebaseAuth = FirebaseAuth.instance;

  AuthStatus _status = AuthStatus.uninitialized;
  AuthStatus get status => _status;

  ///
  AuthProvider({
    required this.firestore,
    required this.localStorage,
  }) {
    firebaseAuth.authStateChanges().listen((user) {
      if (user == null &&
          ![AuthStatus.uninitialized, AuthStatus.authenticating]
              .contains(_status)) {
        handleSignOut();
      }
    });
  }

  /// Google Sign-in
  Future<UserCredential?> _signInWithGoogle() async {
    GoogleSignInAccount? gUser = await gSignIn.signIn();

    // Google Sign In abandoned
    if (gUser == null) {
      // TODO: logger

      _status = AuthStatus.authenticateCanceled;
      notifyListeners();

      return null;
    }

    GoogleSignInAuthentication? gAuth = await gUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    // TODO: Handle exception when email address existed but different provider
    return await firebaseAuth.signInWithCredential(credential);
  }

  /// Facebook Sign-in
  Future<UserCredential?> _signInWithFacebook() async {
    final LoginResult fbAuth = await FacebookAuth.instance.login();

    switch (fbAuth.status) {
      case LoginStatus.cancelled:
        // TODO: logger
        // fbAuth.message;
        _status = AuthStatus.authenticateCanceled;
        notifyListeners();
        break;

      case LoginStatus.failed:
        // TODO: logger
        // fbAuth.message;
        _status = AuthStatus.authenticateError;
        notifyListeners();
        break;

      case LoginStatus.operationInProgress:
        // ? Not sure
        break;

      case LoginStatus.success:
        final accessToken = fbAuth.accessToken;

        if (accessToken != null) {
          final OAuthCredential credential =
              FacebookAuthProvider.credential(accessToken.token);

          // TODO: Handle exception when email address existed but different provider
          return await firebaseAuth.signInWithCredential(credential);
        }

        // TODO: logger
        _status = AuthStatus.authenticateException;
        notifyListeners();
        break;
    }

    return null;
  }

  ///
  Future<bool> handleSignIn(SignInProvider provider) async {
    late UserModel userModel;
    late UserCredential? credential;

    _status = AuthStatus.authenticating;
    notifyListeners();

    switch (provider) {
      case SignInProvider.google:
        {
          credential = await _signInWithGoogle();
        }
        break;

      case SignInProvider.facebook:
        {
          credential = await _signInWithFacebook();
        }
        break;
    }

    User? firebaseUser = credential?.user;

    if (firebaseUser == null) {
      _status = AuthStatus.authenticateError;
      notifyListeners();

      return false;
    }

    // Check the user existence in Firestore
    final QuerySnapshot result = await firestore
        .collection(UserModel.collection)
        .where(UserFields.uid.name, isEqualTo: firebaseUser.uid)
        .get();
    final List<DocumentSnapshot> documents = result.docs;

    if (documents.isEmpty) {
      // New user
      userModel = UserModel.fromUser(firebaseUser);
      firestore
          .collection(UserModel.collection)
          .doc(firebaseUser.uid)
          .set(userModel.toJSON());
    } else {
      // Existing signed up user
      DocumentSnapshot docSnapshot = documents[0];
      userModel = UserModel.fromDocument(docSnapshot);
    }

    // Keep user data in the local storage
    await localStorage.setString(UserFields.uid.name, userModel.uid);
    await localStorage.setString(UserFields.email.name, userModel.email);
    await localStorage.setString(UserFields.photoUrl.name, userModel.photoUrl);
    await localStorage.setString(
        UserFields.phoneNumber.name, userModel.phoneNumber);
    await localStorage.setString(
        UserFields.displayName.name, userModel.displayName);

    _status = AuthStatus.authenticated;
    notifyListeners();

    return true;
  }

  ///
  Future<void> handleSignOut() async {
    final providerId = firebaseAuth.currentUser?.providerData[0].providerId;

    if (providerId != null) {
      await firebaseAuth.signOut();

      switch (providerId) {
        case 'google.com':
          await gSignIn.signOut();
          break;

        case 'facebook.com':
          // TODO
          break;
      }
    }

    await localStorage.clear();

    _status = AuthStatus.uninitialized;
    notifyListeners();
  }

  ///
  Future<void> handleException() async {
    await localStorage.clear();

    _status = AuthStatus.authenticateException;
    notifyListeners();
  }
}
