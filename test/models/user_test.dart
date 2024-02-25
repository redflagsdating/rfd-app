import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:red_flags/models/user.dart';

import '../global.dart' as global;

void main() {
  test("UserModel read/write converter", () async {
    final listEq = const ListEquality().equals;
    final userModel = global.userModel;

    await global.fakeUsersRef.doc(global.uid).set(userModel);

    final user = await global.fakeUsersRef
        .where(UserFields.uid.name, isEqualTo: global.uid)
        .get();
    expect(user.docs.isEmpty, isFalse);
    final userData = user.docs.first.data();

    expect(userData.email == userModel.email, isTrue);
    expect(userData.createdAt == userModel.createdAt, isTrue);
    expect(userData.onboarded == userModel.onboarded, isTrue);
    expect(userData.verified == userModel.verified, isTrue);
    expect(userData.verifySubmitted == userModel.verifySubmitted, isTrue);
    expect(userData.photoUrl == userModel.photoUrl, isTrue);
    expect(userData.firstName == userModel.firstName, isTrue);
    expect(userData.lastName == userModel.lastName, isTrue);
    expect(userData.displayName == userModel.displayName, isTrue);
    expect(userData.dob == userModel.dob, isTrue);
    expect(userData.gender == userModel.gender, isTrue);
    expect(listEq(userData.genderFor, userModel.genderFor), isTrue);
    expect(userData.phoneNumber == userModel.phoneNumber, isTrue);
    expect(userData.locality == userModel.locality, isTrue);
    expect(listEq(userData.latlng, userModel.latlng), isTrue);
    expect(listEq(userData.redFlags, userModel.redFlags), isTrue);
    expect(listEq(userData.greenFlags, userModel.greenFlags), isTrue);
    expect(mapEquals(userData.realTalk, userModel.realTalk), isTrue);
  });
}
