import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
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

class AuthProvider extends ChangeNotifier {
  final GoogleSignIn gSignIn;
  final FirebaseAuth firebaseAuth;
  final SharedPreferences localStorage;
  final FirebaseFirestore firebaseFirestore;

  AuthStatus _status = AuthStatus.uninitialized;

  AuthStatus get status => _status;

  AuthProvider({
    required this.gSignIn,
    required this.firebaseAuth,
    required this.localStorage,
    required this.firebaseFirestore,
  });

  /// Google Sign-in provider
  Future<UserCredential?> _signInWithGoogle() async {
    GoogleSignInAccount? gUser = await gSignIn.signIn();

    // Google Sign In abandoned
    if (gUser == null) {
      _status = AuthStatus.authenticateCanceled;
      notifyListeners();

      return null;
    }

    GoogleSignInAuthentication? gAuth = await gUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    return await firebaseAuth.signInWithCredential(credential);
  }

  /// Facebook Sign-in provider
  Future<UserCredential?> _signInWithFacebook() async {
    return null;
  }

  /// TODO: Refactor to support multiple providers check
  Future<bool> isSignedIn() async {
    bool isSignedIn = await gSignIn.isSignedIn();

    return isSignedIn &&
        localStorage.getString(UserFields.id.name)?.isNotEmpty == true;
  }

  ///
  void handleException() {
    _status = AuthStatus.authenticateException;
    notifyListeners();
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
    final QuerySnapshot result = await firebaseFirestore
        .collection(UserModel.collection)
        .where(UserFields.id.name, isEqualTo: firebaseUser.uid)
        .get();
    final List<DocumentSnapshot> documents = result.docs;

    if (documents.isEmpty) {
      // New user
      userModel = UserModel.fromUser(firebaseUser);
      firebaseFirestore
          .collection(UserModel.collection)
          .doc(firebaseUser.uid)
          .set(userModel.toJSON());
    } else {
      // Existing signed up user
      DocumentSnapshot docSnapshot = documents[0];
      userModel = UserModel.fromDocument(docSnapshot);
    }

    // Keep user data in the local storage
    await localStorage.setString(UserFields.id.name, userModel.id);
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

  /// TODO: Support multiple providers signout
  Future<void> handleSignOut() async {
    _status = AuthStatus.uninitialized;

    await localStorage.clear();

    await firebaseAuth.signOut();
    await gSignIn.disconnect();
    await gSignIn.signOut();
  }
}
