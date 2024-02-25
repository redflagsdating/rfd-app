library global;

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/services/logger_provider.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const uid = "akUecK0mXeNop2a4nTSdTVRExoA2";

late AppLocalizations l10n;
late UserProvider userProvider;
late SharedPreferences localStorage;

final userModel = UserModel(
  uid: uid,
  email: "example@email.com",
  createdAt: DateTime(1991, 01, 01, 00, 00),
  onboarded: false,
  verified: false,
  verifySubmitted: false,
  photoUrl: "https://picsum.photos/200/300",
  firstName: "John",
  lastName: "Smith",
  displayName: "Johnny",
  dob: DateTime(1991, 01, 01, 00, 00),
  gender: Gender.man.name,
  genderFor: [Gender.woman.name],
  phoneNumber: "+61411111111",
  locality: 'Sydney',
  // Latitude and longitude of locality
  latlng: const [-33.962008, 151.05542],
  redFlags: const ['Selfish', 'Cocky'],
  greenFlags: const ['Kind', 'Thoughtful'],
  realTalk: const {
    'What would you never want to change about yourself?':
        'People seem to always think that reinventing themselves is the best thing to do when they find themselves in a rut. People want to change their location, change their friends, change the things they like to do.'
  },
);
final loggerProvider = LoggerProvider(silent: true);
final fakeUsersRef = FakeFirebaseFirestore()
    .collection('users')
    .withConverter<UserModel>(
      fromFirestore: (snapshots, _) => UserModel.fromJson(snapshots.data()!),
      toFirestore: (user, _) => user.toJson(),
    );
