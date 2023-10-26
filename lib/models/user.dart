import 'package:cloud_firestore/cloud_firestore.dart'
    show Timestamp, FirebaseFirestore;
import 'package:flutter/material.dart';

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
  reside,
  phoneNumber,
  onboarding,
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
    required this.onboarding,
    required this.verified,
    required this.verifySubmitted,
    this.photoUrl,
    this.firstName,
    this.lastName,
    this.displayName,
    this.dob,
    this.gender,
    this.genderFor,
    this.reside,
    this.phoneNumber,
  });

  final String uid;
  final String email;
  final DateTime createdAt;
  final bool onboarding;
  final bool verified;
  final bool verifySubmitted;
  final String? photoUrl;
  final String? firstName;
  final String? lastName;
  final String? displayName;
  final DateTime? dob;
  final String? gender;
  final String? genderFor;
  final String? reside;
  final String? phoneNumber;

//
  Map<String, dynamic> toJson() {
    return {
      UserFields.uid.name: uid,
      UserFields.email.name: email,
      UserFields.createdAt.name: createdAt,
      UserFields.onboarding.name: onboarding,
      UserFields.verified.name: verified,
      UserFields.verifySubmitted.name: verifySubmitted,
      UserFields.photoUrl.name: photoUrl,
      UserFields.firstName.name: firstName,
      UserFields.lastName.name: lastName,
      UserFields.displayName.name: displayName,
      UserFields.dob.name: dob,
      UserFields.gender.name: gender,
      UserFields.genderFor.name: genderFor,
      UserFields.reside.name: reside,
      UserFields.phoneNumber.name: phoneNumber,
    };
  }

//
  UserModel.fromJson(Map<String, dynamic> json)
      : this(
          uid: json[UserFields.uid.name]!,
          email: json[UserFields.email.name]!,
          createdAt: (json[UserFields.createdAt.name]! as Timestamp).toDate(),
          onboarding: json[UserFields.onboarding.name]!,
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
          genderFor: json[UserFields.genderFor.name],
          reside: json[UserFields.reside.name],
          phoneNumber: json[UserFields.phoneNumber.name],
        );
}

final usersRef = FirebaseFirestore.instance
    .collection('users')
    .withConverter<UserModel>(
      fromFirestore: (snapshots, _) => UserModel.fromJson(snapshots.data()!),
      toFirestore: (user, _) => user.toJson(),
    );
