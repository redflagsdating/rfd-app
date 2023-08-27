import 'package:cloud_firestore/cloud_firestore.dart' show DocumentSnapshot;
import 'package:firebase_auth/firebase_auth.dart' show User;

enum UserFields {
  uid,
  email,
  displayName,
  photoUrl,
  createdAt,
  phoneNumber,
}

///
class UserModel {
  // Firestore Database collection name
  static const collection = 'users';

  final String uid;
  final String email;
  final String createdAt;
  final String photoUrl;
  final String phoneNumber;
  final String displayName;

  const UserModel({
    required this.uid,
    required this.email,
    required this.createdAt,
    required this.photoUrl,
    required this.phoneNumber,
    required this.displayName,
  });

  ///
  Map<String, String> toJSON() {
    return {
      UserFields.uid.name: uid,
      UserFields.email.name: email,
      UserFields.createdAt.name: createdAt,
      UserFields.photoUrl.name: photoUrl,
      UserFields.phoneNumber.name: phoneNumber,
      UserFields.displayName.name: displayName,
    };
  }

  /// Covert Firebase User into UserModel
  factory UserModel.fromUser(User? firebaseUser) {
    return UserModel(
      uid: firebaseUser?.uid ?? '',
      email: firebaseUser?.email ?? '',
      createdAt: firebaseUser?.uid != null
          ? DateTime.now().millisecondsSinceEpoch.toString()
          : '',
      photoUrl: firebaseUser?.photoURL ?? '',
      phoneNumber: firebaseUser?.phoneNumber ?? '',
      displayName: firebaseUser?.displayName ?? '',
    );
  }

  /// Convert DocumentSnapshot from Firestore query result to UserModel
  factory UserModel.fromDocument(DocumentSnapshot? doc) {
    return UserModel(
      uid: doc?.get(UserFields.uid.name) ?? '',
      email: doc?.get(UserFields.email.name) ?? '',
      createdAt: doc?.get(UserFields.createdAt.name) ?? '',
      photoUrl: doc?.get(UserFields.photoUrl.name) ?? '',
      phoneNumber: doc?.get(UserFields.phoneNumber.name) ?? '',
      displayName: doc?.get(UserFields.displayName.name) ?? '',
    );
  }
}
