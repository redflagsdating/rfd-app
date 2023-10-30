import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:red_flags/models/user.dart';

const uid = "akUecK0mXeNop2a4nTSdTVRExoA2";

void main() {
  late CollectionReference<UserModel> users;

  setUpAll(() {
    users =
        FakeFirebaseFirestore().collection('users').withConverter<UserModel>(
              fromFirestore: (snapshots, _) =>
                  UserModel.fromJson(snapshots.data()!),
              toFirestore: (user, _) => user.toJson(),
            );
  });
  test("UserModel read/write converter", () async {
    final userModel = UserModel(
      uid: uid,
      email: "example@email.com",
      createdAt: DateTime.now(),
      onboarded: false,
      verified: false,
      verifySubmitted: false,
      photoUrl: "https://picsum.photos/200/300",
      firstName: "John",
      lastName: "Smith",
      displayName: "Johnny",
      dob: DateTime.now(),
      gender: Gender.man.name,
      genderFor: [Gender.woman.name],
      phoneNumber: "+61411111111",
    );

    await users.doc(uid).set(userModel);

    final user = await users.where(UserFields.uid.name, isEqualTo: uid).get();
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
    expect(const ListEquality().equals(userData.genderFor, userModel.genderFor),
        isTrue);
    expect(userData.phoneNumber == userModel.phoneNumber, isTrue);
  });
}
