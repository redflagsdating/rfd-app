import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  void handleException() {
    _status = AuthStatus.authenticateException;
    notifyListeners();
  }

  Future<bool> isSignedIn() async {
    bool isSignedIn = await gSignIn.isSignedIn();

    return isSignedIn && localStorage.getString('id')?.isNotEmpty == true;
  }

  Future<bool> handleSignIn() async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    GoogleSignInAccount? gUser = await gSignIn.signIn();

    // Authentication cancelled
    if (gUser == null) {
      _status = AuthStatus.authenticateCanceled;
      notifyListeners();

      return false;
    }

    GoogleSignInAuthentication? gAuth = await gUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );
    User? firebaseUser =
        (await firebaseAuth.signInWithCredential(credential)).user;

    // Authentication error
    if (firebaseUser == null) {
      _status = AuthStatus.authenticateError;
      notifyListeners();

      return false;
    }

    final QuerySnapshot result = await firebaseFirestore
        .collection('users')
        .where('id', isEqualTo: firebaseUser.uid)
        .get();
    final List<DocumentSnapshot> documents = result.docs;

    if (documents.isEmpty) {
      // Save new user to Firestore
      firebaseFirestore.collection('users').doc(firebaseUser.uid).set({
        'id': firebaseUser.uid,
        'email': firebaseUser.email,
        'photoUrl': firebaseUser.photoURL,
        'phoneNumber': firebaseUser.phoneNumber,
        'displayName': firebaseUser.displayName,
        'createdAt': DateTime.now().millisecondsSinceEpoch.toString()
      });

      // Write new user to local storage
      await localStorage.setString('id', firebaseUser.uid);
      await localStorage.setString('email', firebaseUser.email ?? '');
      await localStorage.setString('photoUrl', firebaseUser.photoURL ?? '');
      await localStorage.setString(
          'phoneNumber', firebaseUser.phoneNumber ?? '');
      await localStorage.setString(
          'displayName', firebaseUser.displayName ?? '');
    } else {
      // Already signed up, retrieve data from Firestore
      DocumentSnapshot docSnapshot = documents[0];

      await localStorage.setString('id', docSnapshot.get('id'));
      await localStorage.setString('email', docSnapshot.get('email'));
      await localStorage.setString('photoUrl', docSnapshot.get('photoUrl'));
      await localStorage.setString(
          'phoneNumber', docSnapshot.get('phoneNumber'));
      await localStorage.setString(
          'displayName', docSnapshot.get('displayName'));
    }

    _status = AuthStatus.authenticated;
    notifyListeners();

    return true;
  }

  Future<void> handleSignOut() async {
    _status = AuthStatus.uninitialized;

    await firebaseAuth.signOut();
    await gSignIn.disconnect();
    await gSignIn.signOut();
  }
}
