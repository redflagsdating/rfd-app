import 'package:cloud_firestore/cloud_firestore.dart'
    show Timestamp, FirebaseFirestore;
import 'package:flutter/material.dart';

enum Gender {
  man,
  woman,
  nonBinary,
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
  phoneNumber,
  onboarded,
  verified,
  verifySubmitted,
}

///
@immutable
class UserModel {
  const UserModel({
    required this.uid,
    required this.email,
    required this.createdAt,
    required this.onboarded,
    required this.verified,
    required this.verifySubmitted,
    this.photoUrl,
    this.firstName,
    this.lastName,
    this.displayName,
    this.dob,
    this.gender,
    this.genderFor,
    this.locality,
    this.phoneNumber,
  });

  final String uid;
  final String email;
  final DateTime createdAt;
  final bool onboarded;
  final bool verified;
  final bool verifySubmitted;
  final String? photoUrl;
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final DateTime? dob;
  final String? gender;
  final List<String>? genderFor;
  final String? locality;
  final String? phoneNumber;

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
      UserFields.phoneNumber.name: phoneNumber,
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
          phoneNumber: json[UserFields.phoneNumber.name],
        );
}

final usersRef = FirebaseFirestore.instance
    .collection('users')
    .withConverter<UserModel>(
      fromFirestore: (snapshots, _) => UserModel.fromJson(snapshots.data()!),
      toFirestore: (user, _) => user.toJson(),
    );
