import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../global.dart' as global;

void main() {
  final listEq = const ListEquality().equals;

  setUp(() async {
    await global.userProvider.createUser(global.userModel);
  });

  test('UserProvider.userDocRef getter', () {
    expect(
        global.fakeUsersRef.doc(global.uid) == global.userProvider.userDocRef,
        isTrue);
  });

  test('UserProvider > createUser / getCurrentUser / cache getter methods',
      () async {
    final userModel = global.userModel;
    final userProvider = global.userProvider;
    final user = await userProvider.getCurrentUser();

    expect(user, isNotNull);
    // Not need to verify all fields as test is covered by user_test.dart
    expect(user?.uid == global.uid, isTrue);

    // Verify local cache
    expect(userProvider.getIdCache() == userModel.uid, isTrue);
    expect(userProvider.getEmailCache() == userModel.email, isTrue);
    expect(userProvider.getOnboardedCache() == userModel.onboarded, isTrue);
    expect(userProvider.getVerifiedCache() == userModel.verified, isTrue);
    expect(userProvider.getVerifySubmittedCache() == userModel.verifySubmitted,
        isTrue);
    expect(userProvider.getPhotoUrlCache() == userModel.photoUrl, isTrue);
    expect(userProvider.getFirstNameCache() == userModel.firstName, isTrue);
    expect(userProvider.getLastNameCache() == userModel.lastName, isTrue);
    expect(userProvider.getDisplayNameCache() == userModel.displayName, isTrue);
    expect(
        userProvider.getDobCache()?.isAtSameMomentAs(userModel.dob!), isTrue);
    expect(userProvider.getGenderCache() == userModel.gender, isTrue);
    expect(
        listEq(userProvider.getGenderForCache(), userModel.genderFor), isTrue);
    expect(userProvider.getLocalityCache() == userModel.locality, isTrue);
    expect(listEq(userProvider.getRedFlagsCache(), userModel.redFlags), isTrue);
    expect(listEq(userProvider.getGreenFlagsCache(), userModel.greenFlags),
        isTrue);
    expect(
        mapEquals(userProvider.getRealTalkCache(), userModel.realTalk), isTrue);
  });

  test('UserProvider.setId()', () async {
    // String field local cache only
    expect(await global.userProvider.setId('123456789'), isTrue);
    expect(global.userProvider.getIdCache() == '123456789', isTrue);
    expect((await global.userProvider.getCurrentUser())?.uid == global.uid,
        isTrue);

    // String field local and remote database
    expect(await global.userProvider.setId('abcdefghijk', localOnly: false),
        isTrue);
    expect(global.userProvider.getIdCache() == 'abcdefghijk', isTrue);
    expect((await global.userProvider.getCurrentUser())?.uid == 'abcdefghijk',
        isTrue);
  });

  test('UserProvider.setRedFlags()', () async {
    // List<String> field local cache only
    expect(await global.userProvider.setRedFlags(['Smoker']), isTrue);
    expect(listEq(global.userProvider.getRedFlagsCache(), ['Smoker']), isTrue);
    expect(
        listEq(
          (await global.userProvider.getCurrentUser())?.redFlags,
          global.userModel.redFlags,
        ),
        isTrue);

    // List<String> field local and remote database
    expect(
        await global.userProvider
            .setRedFlags(['Smoker', 'Ego'], localOnly: false),
        isTrue);
    expect(listEq(global.userProvider.getRedFlagsCache(), ['Smoker', 'Ego']),
        isTrue);
    expect(
        listEq(
          (await global.userProvider.getCurrentUser())?.redFlags,
          ['Smoker', 'Ego'],
        ),
        isTrue);
  });

  test('UserProvider.setOnboarded()', () async {
    // Bool field local cache only
    expect(await global.userProvider.setOnboarded(true), isTrue);
    expect(global.userProvider.getOnboardedCache(), isTrue);
    expect((await global.userProvider.getCurrentUser())?.onboarded, isFalse);

    // Bool field local and remote database
    expect(
        await global.userProvider.setOnboarded(true, localOnly: false), isTrue);
    expect(global.userProvider.getOnboardedCache(), isTrue);
    expect((await global.userProvider.getCurrentUser())?.onboarded, isTrue);
  });

  test('UserProvider.setDob()', () async {
    // DateTime field local cache only
    expect(
        await global.userProvider.setDob(DateTime(1980, 12, 12, 0, 0)), isTrue);
    expect(
        DateTime(1980, 12, 12, 0, 0)
            .isAtSameMomentAs(global.userProvider.getDobCache()!),
        isTrue);
    expect(
        (await global.userProvider.getCurrentUser())
            ?.dob
            ?.isAtSameMomentAs(DateTime(1980, 12, 12, 0, 0)),
        isFalse);

    // DateTime field local and remote database
    expect(
        await global.userProvider
            .setDob(DateTime(1980, 12, 12, 0, 0), localOnly: false),
        isTrue);
    expect(
        DateTime(1980, 12, 12, 0, 0)
            .isAtSameMomentAs(global.userProvider.getDobCache()!),
        isTrue);
    expect(
        (await global.userProvider.getCurrentUser())
            ?.dob
            ?.isAtSameMomentAs(DateTime(1980, 12, 12, 0, 0)),
        isTrue);
  });

  test('UserProvider.setRealTalk()', () async {
    // Map<String, String> field local cache only
    expect(await global.userProvider.setRealTalk({"aaa": "bbb"}), isTrue);
    expect(mapEquals(global.userProvider.getRealTalkCache(), {"aaa": "bbb"}),
        isTrue);
    expect(
        mapEquals((await global.userProvider.getCurrentUser())?.realTalk,
            {"aaa": "bbb"}),
        isFalse);

    // Map<String, String> field local and remote database
    expect(
        await global.userProvider.setRealTalk({"aaa": "bbb"}, localOnly: false),
        isTrue);
    expect(mapEquals(global.userProvider.getRealTalkCache(), {"aaa": "bbb"}),
        isTrue);
    expect(
        (await global.userProvider.getCurrentUser())
            ?.realTalk
            ?.containsKey(global.userModel.realTalk?.keys.first),
        isTrue);
    expect(
        (await global.userProvider.getCurrentUser())
            ?.realTalk
            ?.containsKey('aaa'),
        isTrue);
  });

  test('UserProvider.purgeUserCache', () async {
    expect(global.userProvider.getIdCache() == global.userModel.uid, isTrue);

    expect(await global.userProvider.purgeUserCache(), isTrue);
    expect(global.userProvider.getIdCache(), isEmpty);
    expect(global.userProvider.getFirstNameCache(), isEmpty);
    expect(global.userProvider.getLastNameCache(), isEmpty);
    expect(global.userProvider.getDisplayNameCache(), isEmpty);
    expect(global.userProvider.getPhotoUrlCache(), isEmpty);
    expect(global.userProvider.getGenderCache(), isEmpty);
    expect(global.userProvider.getLocalityCache(), isEmpty);
    expect(global.userProvider.getOnboardedCache(), isNull);
    expect(global.userProvider.getVerifiedCache(), isNull);
    expect(global.userProvider.getVerifySubmittedCache(), isNull);
    expect(global.userProvider.getDobCache(), isNull);
    expect(global.userProvider.getRealTalkCache(), isNull);
    expect(global.userProvider.getGenderForCache(), isEmpty);
    expect(global.userProvider.getRedFlagsCache(), isEmpty);
    expect(global.userProvider.getGreenFlagsCache(), isEmpty);

    expect(await global.userProvider.getId() == global.userModel.uid, isTrue);
    expect(
        await global.userProvider.getFirstName() == global.userModel.firstName,
        isTrue);
    expect(await global.userProvider.getLastName() == global.userModel.lastName,
        isTrue);
    expect(
        await global.userProvider.getDisplayName() ==
            global.userModel.displayName,
        isTrue);
    expect(await global.userProvider.getPhotoUrl() == global.userModel.photoUrl,
        isTrue);
    expect(await global.userProvider.getGender() == global.userModel.gender,
        isTrue);
    expect(await global.userProvider.getLocality() == global.userModel.locality,
        isTrue);
    expect(await global.userProvider.getOnboarded(), isFalse);
    expect(await global.userProvider.getVerified(), isFalse);
    expect(await global.userProvider.getVerifySubmitted(), isFalse);
    expect(
        global.userModel.dob
            ?.isAtSameMomentAs((await global.userProvider.getDob())!),
        isTrue);
    expect(await global.userProvider.getGenderFor(), isNotEmpty);
    expect(await global.userProvider.getRedFlags(), isNotEmpty);
    expect(await global.userProvider.getGreenFlags(), isNotEmpty);
  });
}
