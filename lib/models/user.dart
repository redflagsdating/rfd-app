import 'package:cloud_firestore/cloud_firestore.dart'
    show FirebaseFirestore, Timestamp;
import 'package:flutter/material.dart';

enum Gender {
  man,
  woman,
  nonBinary,
}

enum UserBoolFields {
  onboarded,
  verified,
  verifySubmitted,
}

enum UserStringListFields {
  genderFor,
  redFlags,
  greenFlags,
  connections,
}

enum UserDoubleListFields {
  latlng,
}

enum UserDateTimeFields {
  dob,
  createdAt,
}

enum UserStringFields {
  uid,
  email,
  photoUrl,
  firstName,
  lastName,
  displayName,
  gender,
  locality,
  phoneNumber,
  realTalk,
}

enum UserFields {
  uid,
  email,
  createdAt,
  photoUrl,
  firstName,
  lastName,
  displayName,
  dob,
  gender,
  genderFor,
  locality,
  latlng,
  phoneNumber,
  onboarded,
  verified,
  verifySubmitted,
  realTalk,
  redFlags,
  greenFlags,
  connections,
  fcmToken,
}

@immutable
class UserModel {
  const UserModel({
    required this.uid,
    required this.email,
    required this.onboarded,
    required this.verified,
    required this.verifySubmitted,
    this.createdAt,
    this.photoUrl,
    this.firstName,
    this.lastName,
    this.displayName,
    this.dob,
    this.gender,
    this.genderFor,
    this.locality,
    this.latlng,
    this.phoneNumber,
    this.realTalk,
    this.redFlags,
    this.greenFlags,
    this.connections,
    this.fcmToken,
  });

  final String uid;
  final String email;
  final bool onboarded;
  final bool verified;
  final bool verifySubmitted;
  final DateTime? createdAt;
  final String? photoUrl;
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final DateTime? dob;
  final String? gender;
  final List<String>? genderFor;
  final String? locality;
  final List<double>? latlng;
  final String? phoneNumber;
  final Map<String, String>? realTalk;
  final List<String>? redFlags;
  final List<String>? greenFlags;
  // List of document id of connection collection
  final List<String>? connections;
  // Firebase Cloud Messaging token
  final String? fcmToken;

  Map<String, dynamic> toJson() {
    return {
      UserFields.uid.name: uid,
      UserFields.email.name: email,
      UserFields.createdAt.name: createdAt,
      UserFields.onboarded.name: onboarded,
      UserFields.verified.name: verified,
      UserFields.verifySubmitted.name: verifySubmitted,
      UserFields.photoUrl.name: photoUrl,
      UserFields.firstName.name: firstName,
      UserFields.lastName.name: lastName,
      UserFields.displayName.name: displayName,
      UserFields.dob.name: dob,
      UserFields.gender.name: gender,
      UserFields.genderFor.name: genderFor,
      UserFields.locality.name: locality,
      UserFields.latlng.name: latlng,
      UserFields.phoneNumber.name: phoneNumber,
      UserFields.realTalk.name: realTalk,
      UserFields.redFlags.name: redFlags,
      UserFields.greenFlags.name: greenFlags,
      UserFields.connections.name: connections,
      UserFields.fcmToken.name: fcmToken,
    };
  }

  UserModel.fromJson(Map<String, dynamic> json)
      : this(
          uid: json[UserFields.uid.name]!,
          email: json[UserFields.email.name]!,
          createdAt: (json[UserFields.createdAt.name]! as Timestamp).toDate(),
          onboarded: json[UserFields.onboarded.name]!,
          verified: json[UserFields.verified.name]!,
          verifySubmitted: json[UserFields.verifySubmitted.name]!,
          photoUrl: json[UserFields.photoUrl.name],
          firstName: json[UserFields.firstName.name],
          lastName: json[UserFields.lastName.name],
          displayName: json[UserFields.displayName.name],
          dob: json[UserFields.dob.name] is Timestamp
              ? json[UserFields.dob.name].toDate()
              : null,
          gender: json[UserFields.gender.name],
          genderFor: json[UserFields.genderFor.name]?.cast<String>(),
          locality: json[UserFields.locality.name],
          latlng: json[UserFields.latlng.name]?.cast<double>(),
          phoneNumber: json[UserFields.phoneNumber.name],
          realTalk: json[UserFields.realTalk.name]?.cast<String, String>(),
          redFlags: json[UserFields.redFlags.name]?.cast<String>(),
          greenFlags: json[UserFields.greenFlags.name]?.cast<String>(),
          connections: json[UserFields.connections.name]?.cast<String>(),
          fcmToken: json[UserFields.fcmToken.name],
        );
}

final usersRef = FirebaseFirestore.instance
    .collection('users')
    .withConverter<UserModel>(
      fromFirestore: (snapshots, _) => UserModel.fromJson(snapshots.data()!),
      toFirestore: (user, _) => user.toJson(),
    );
