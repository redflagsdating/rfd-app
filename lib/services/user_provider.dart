import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:red_flags/models/user.dart' hide usersRef;
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  DocumentReference<UserModel>? _userDocRef;
  DocumentReference<UserModel>? get userDocRef => _userDocRef;

  UserProvider({
    required this.logger,
    required this.localStorage,
    required this.usersRef,
  });

  final Logger logger;
  final SharedPreferences localStorage;
  final CollectionReference<UserModel> usersRef;

  // General user filed getter method from Firebase
  Future<dynamic> _getField(String field) async {
    final json = (await getCurrentUser())?.toJson();
    return json != null ? json[field] : null;
  }

  bool? _getBoolFieldCache(UserBoolFields field) {
    return localStorage.getBool(field.name);
  }

  String _getStringFieldCache(UserStringFields field) {
    return localStorage.getString(field.name) ?? "";
  }

  List<String> _getStringListFieldCache(UserStringListFields field) {
    return localStorage.getStringList(field.name) ?? [];
  }

  DateTime? _getDateTimeFieldCache(UserDateTimeFields field) {
    final timestamp = localStorage.getInt(field.name);

    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }

    return null;
  }

  Future<bool?> _getBoolField(UserBoolFields field) async {
    final cached = _getBoolFieldCache(field);

    if (cached != null) {
      return Future.value(cached);
    }

    return await _getField(field.name);
  }

  Future<String?> _getStringField(UserStringFields field) async {
    final cached = localStorage.getString(field.name);

    if (cached != null) {
      return Future.value(cached);
    }

    return await _getField(field.name);
  }

  Future<List<String>?> _getStringListField(UserStringListFields field) async {
    final cached = localStorage.getStringList(field.name);

    if (cached != null) {
      return Future.value(cached);
    }

    return await _getField(field.name);
  }

  Future<bool?> _setStringField(UserStringFields field, String value,
      {bool? silent, bool? localOnly}) async {
    final result = await localStorage.setString(field.name, value);

    if (localOnly != true) {
      await _userDocRef?.update({field.name: value});
    }

    if (silent != true) {
      notifyListeners();
    }

    return result;
  }

  Future<bool?> _setStingListField(
      UserStringListFields field, List<String> list,
      {bool? silent, bool? localOnly}) async {
    final result = localStorage.setStringList(
      field.name,
      list.toList(),
    );

    if (localOnly != true) {
      await _userDocRef?.update({field.name: list.toList()});
    }

    if (silent != true) {
      notifyListeners();
    }

    return result;
  }

  Future<bool?> _setBoolField(UserBoolFields field, bool value,
      {bool? silent, bool? localOnly}) async {
    final result = localStorage.setBool(field.name, value);

    if (localOnly != true) {
      await _userDocRef?.update({field.name: value});
    }

    if (silent != true) {
      notifyListeners();
    }

    return result;
  }

  Future<bool?> _setDateTimeField(UserDateTimeFields field, DateTime value,
      {bool? silent = true, bool? localOnly = true}) async {
    final result =
        localStorage.setInt(field.name, value.millisecondsSinceEpoch);

    if (localOnly != true) {
      await _userDocRef?.update({field.name: value});
    }

    if (silent != true) {
      notifyListeners();
    }

    return result;
  }

  ///
  ///** External methods */
  ///
  Future<void> createUser(UserModel user) async {
    final ref = usersRef.doc(user.uid);

    _userDocRef = ref;
    await ref.set(user);
    await updateUserCache(user);

    logger.d('New user (${user.email}) is created', time: DateTime.now());
  }

  /// ******************** Dangerous **********************
  /// ****** For delete user account feature mainly *******
  /// Delete user document in Firebase storage permanently and clear local
  /// cache (SharedPreference)
  Future<void> deleteUser() async {
    if (_userDocRef != null) {
      final uid = getIdCache();
      final email = getEmailCache();

      await usersRef.doc(uid).delete();
      _userDocRef = null;
      await localStorage.clear();

      logger.d('Deleted user $email successfully', time: DateTime.now());
    }
  }

  /// Alternative to localStorage.clear() that purges user fields except email,
  ///  intro, providerId and createdAt fields.
  Future<bool> purgeUserCache() async {
    late bool result = true;

    result &= await localStorage.remove(UserFields.uid.name);
    result &= await localStorage.remove(UserFields.photoUrl.name);
    result &= await localStorage.remove(UserFields.phoneNumber.name);
    result &= await localStorage.remove(UserFields.firstName.name);
    result &= await localStorage.remove(UserFields.lastName.name);
    result &= await localStorage.remove(UserFields.displayName.name);
    result &= await localStorage.remove(UserFields.dob.name);
    result &= await localStorage.remove(UserFields.gender.name);
    result &= await localStorage.remove(UserFields.genderFor.name);
    result &= await localStorage.remove(UserFields.locality.name);
    result &= await localStorage.remove(UserFields.phoneNumber.name);
    result &= await localStorage.remove(UserFields.onboarded.name);
    result &= await localStorage.remove(UserFields.verified.name);
    result &= await localStorage.remove(UserFields.verifySubmitted.name);
    result &= await localStorage.remove(UserFields.realTalk.name);
    result &= await localStorage.remove(UserFields.redFlags.name);
    result &= await localStorage.remove(UserFields.greenFlags.name);

    logger.d('Local storage purged', time: DateTime.now());

    return result;
  }

  Future<void> updateUserCache(UserModel user) async {
    _userDocRef = usersRef.doc(user.uid);

    final dob = user.dob;
    final createdAt = user.createdAt;

    await setId(user.uid);
    await setEmail(user.email);
    await setFirstName(user.firstName ?? "");
    await setLastName(user.lastName ?? "");
    await setDisplayName(user.displayName ?? "");
    await setPhoneNumber(user.phoneNumber ?? "");
    await setGender(user.gender ?? "");
    await setLocality(user.locality ?? "");
    await setPhotoUrl(user.photoUrl ?? "");
    await setGenderFor(user.genderFor ?? []);
    await setRealTalk(user.realTalk ?? {});
    await setRedFlags(user.redFlags ?? []);
    await setGreenFlags(user.greenFlags ?? []);
    await setOnboarded(user.onboarded);
    await setVerified(user.verified);
    await setVerifySubmitted(user.verifySubmitted);

    if (dob != null) {
      await setDob(dob);
    }

    if (createdAt != null) {
      await setCreatedAt(createdAt);
    }

    logger.d(
      'Successfully update cached user (${user.email}) in local storage',
      time: DateTime.now(),
    );
  }

  UserModel getUserCache() {
    return UserModel(
      uid: getIdCache(),
      email: getEmailCache(),
      createdAt: getCreatedAtCache(),
      onboarded: getOnboardedCache() ?? false,
      verified: getVerifiedCache() ?? false,
      verifySubmitted: getVerifySubmittedCache() ?? false,
      phoneNumber: getPhoneNumberCache(),
      photoUrl: getPhotoUrlCache(),
      firstName: getFirstNameCache(),
      lastName: getLastNameCache(),
      displayName: getDisplayNameCache(),
      dob: getDobCache(),
      gender: getGenderCache(),
      genderFor: getGenderForCache(),
      locality: getLocalityCache(),
      realTalk: getRealTalkCache(),
      redFlags: getRedFlagsCache(),
      greenFlags: getGreenFlagsCache(),
    );
  }

  ///
  ///** External getter methods */
  ///

  ///
  /// Common methods
  ///
  Future<UserModel?> getCurrentUser() async {
    return (await _userDocRef?.get())?.data();
  }

  Future<QuerySnapshot<UserModel>> getUserById(String? uid) async {
    return usersRef.where(UserFields.uid.name, isEqualTo: uid).get();
  }

  ///
  /// String field getter functions catch-only (from SharedPreference)
  ///
  String getIdCache() {
    return _getStringFieldCache(UserStringFields.uid);
  }

  String getEmailCache() {
    return _getStringFieldCache(UserStringFields.email);
  }

  String getFirstNameCache() {
    return _getStringFieldCache(UserStringFields.firstName);
  }

  String getLastNameCache() {
    return _getStringFieldCache(UserStringFields.lastName);
  }

  String getDisplayNameCache() {
    return _getStringFieldCache(UserStringFields.displayName);
  }

  String getPhoneNumberCache() {
    return _getStringFieldCache(UserStringFields.phoneNumber);
  }

  String getGenderCache() {
    return _getStringFieldCache(UserStringFields.gender);
  }

  String getLocalityCache() {
    return _getStringFieldCache(UserStringFields.locality);
  }

  String getPhotoUrlCache() {
    return _getStringFieldCache(UserStringFields.photoUrl);
  }

  ///
  /// List<String> field getter functions catch-only (from SharedPreference)
  ///

  List<String> getGenderForCache() {
    return _getStringListFieldCache(UserStringListFields.genderFor);
  }

  List<String> getRedFlagsCache() {
    return _getStringListFieldCache(UserStringListFields.redFlags);
  }

  List<String> getGreenFlagsCache() {
    return _getStringListFieldCache(UserStringListFields.greenFlags);
  }

  ///
  /// String field getter functions catch-first (fallback to Firebase DB)
  ///

  Future<String?> getId() async {
    return await _getStringField(UserStringFields.uid);
  }

  Future<String?> getEmail() async {
    return await _getStringField(UserStringFields.email);
  }

  Future<String?> getFirstName() async {
    return await _getStringField(UserStringFields.firstName);
  }

  Future<String?> getLastName() async {
    return await _getStringField(UserStringFields.lastName);
  }

  Future<String?> getDisplayName() async {
    return await _getStringField(UserStringFields.displayName);
  }

  Future<String?> getGender() async {
    return await _getStringField(UserStringFields.gender);
  }

  Future<String?> getPhotoUrl() async {
    return await _getStringField(UserStringFields.photoUrl);
  }

  Future<String?> getLocality() async {
    return await _getStringField(UserStringFields.locality);
  }

  ///
  /// List<String? getter functions catch-first (fallback to Firebase DB)
  ///
  Future<List<String>?> getGenderFor() async {
    return await _getStringListField(UserStringListFields.genderFor);
  }

  Future<List<String>?> getGreenFlags() async {
    return await _getStringListField(UserStringListFields.greenFlags);
  }

  Future<List<String>?> getRedFlags() async {
    return await _getStringListField(UserStringListFields.redFlags);
  }

  ///
  /// Boolean field getter functions catch-only
  ///
  bool? getOnboardedCache() {
    return _getBoolFieldCache(UserBoolFields.onboarded);
  }

  bool? getVerifiedCache() {
    return _getBoolFieldCache(UserBoolFields.verified);
  }

  bool? getVerifySubmittedCache() {
    return _getBoolFieldCache(UserBoolFields.verifySubmitted);
  }

  ///
  /// Boolean field getter functions catch-first (fallback to Firebase DB)
  ///
  Future<bool?> getOnboarded() async {
    return await _getBoolField(UserBoolFields.onboarded);
  }

  Future<bool?> getVerified() async {
    /// Always get from database to ensure up-to-date since 3rd-party async
    return await _getField(UserBoolFields.verified.name);
  }

  Future<bool?> getVerifySubmitted() async {
    return await _getBoolField(UserBoolFields.verifySubmitted);
  }

  ///
  /// DateTime field
  ///

  DateTime? getDobCache() {
    return _getDateTimeFieldCache(UserDateTimeFields.dob);
  }

  DateTime? getCreatedAtCache() {
    return _getDateTimeFieldCache(UserDateTimeFields.createdAt);
  }

  ///
  /// Other types
  ///
  Future<DateTime?> getDob() async {
    final cached = getDobCache();

    if (cached != null) {
      return Future.value(cached);
    }

    return await _getField(UserFields.dob.name);
  }

  int getAge(DateTime dob) {
    return (DateTime.now().difference(dob).inDays / 365).floor();
  }

  Map<String, String>? getRealTalkCache() {
    final rawData = _getStringFieldCache(UserStringFields.realTalk);

    try {
      final map = (json.decode(rawData) as Map).cast<String, String>();

      if (map.isEmpty) {
        return null;
      }

      return map;
    } catch (e) {
      logger.d(e, time: DateTime.now());
    }

    return null;
  }

  ///
  ///** External setters */
  ///

  ///
  /// String field setter functions
  ///
  Future<bool?> setId(String value,
      {bool? silent = true, bool? localOnly = true}) {
    return _setStringField(
      UserStringFields.uid,
      value,
      silent: silent,
      localOnly: localOnly,
    );
  }

  Future<bool?> setEmail(String value,
      {bool? silent = true, bool? localOnly = true}) {
    return _setStringField(
      UserStringFields.email,
      value,
      silent: silent,
      localOnly: localOnly,
    );
  }

  Future<bool?> setFirstName(String value,
      {bool? silent = true, bool? localOnly = true}) {
    return _setStringField(
      UserStringFields.firstName,
      value,
      silent: silent,
      localOnly: localOnly,
    );
  }

  Future<bool?> setLastName(String value,
      {bool? silent = true, bool? localOnly = true}) {
    return _setStringField(
      UserStringFields.lastName,
      value,
      silent: silent,
      localOnly: localOnly,
    );
  }

  Future<bool?> setDisplayName(String value,
      {bool? silent = true, bool? localOnly = true}) {
    return _setStringField(
      UserStringFields.displayName,
      value,
      silent: silent,
      localOnly: localOnly,
    );
  }

  Future<bool?> setPhotoUrl(String value,
      {bool? silent = true, bool? localOnly = true}) {
    return _setStringField(
      UserStringFields.photoUrl,
      value,
      silent: silent,
      localOnly: localOnly,
    );
  }

  Future<bool?> setPhoneNumber(String value,
      {bool? silent = true, bool? localOnly = true}) {
    return _setStringField(
      UserStringFields.phoneNumber,
      value,
      silent: silent,
      localOnly: localOnly,
    );
  }

  Future<bool?> setGender(String value,
      {bool? silent = true, bool? localOnly = true}) {
    return _setStringField(
      UserStringFields.gender,
      value,
      silent: silent,
      localOnly: localOnly,
    );
  }

  Future<bool?> setLocality(String value,
      {bool? silent = true, bool? localOnly = true}) {
    return _setStringField(
      UserStringFields.locality,
      value,
      silent: silent,
      localOnly: localOnly,
    );
  }

  ///
  /// List<String> field setter functions
  ///
  Future<bool?> setGenderFor(List<String> genders,
      {bool? silent = true, bool? localOnly = true}) async {
    return _setStingListField(
      UserStringListFields.genderFor,
      genders,
      silent: silent,
      localOnly: localOnly,
    );
  }

  Future<bool?> setRedFlags(List<String> flags,
      {bool? silent = true, bool? localOnly = true}) async {
    return _setStingListField(
      UserStringListFields.redFlags,
      flags,
      silent: silent,
      localOnly: localOnly,
    );
  }

  Future<bool?> setGreenFlags(List<String> flags,
      {bool? silent = true, bool? localOnly = true}) async {
    return _setStingListField(
      UserStringListFields.greenFlags,
      flags,
      silent: silent,
      localOnly: localOnly,
    );
  }

  ///
  /// Boolean field setter functions
  ///

  Future<bool?> setOnboarded(bool value,
      {bool? silent = true, bool? localOnly = true}) {
    return _setBoolField(
      UserBoolFields.onboarded,
      value,
      localOnly: localOnly,
      silent: silent,
    );
  }

  Future<bool?> setVerified(bool value,
      {bool? silent = true, bool? localOnly = true}) {
    return _setBoolField(
      UserBoolFields.verified,
      value,
      localOnly: localOnly,
      silent: silent,
    );
  }

  Future<bool?> setVerifySubmitted(bool value,
      {bool? silent = true, bool? localOnly = true}) {
    return _setBoolField(
      UserBoolFields.verifySubmitted,
      value,
      localOnly: localOnly,
      silent: silent,
    );
  }

  ///
  /// DateTime field setter functions
  ///
  Future<bool?> setDob(DateTime value,
      {bool? silent = true, bool? localOnly = true}) async {
    return _setDateTimeField(
      UserDateTimeFields.dob,
      value,
      localOnly: localOnly,
      silent: silent,
    );
  }

  Future<bool?> setCreatedAt(DateTime value,
      {bool? silent = true, bool? localOnly = true}) async {
    return _setDateTimeField(
      UserDateTimeFields.createdAt,
      value,
      localOnly: localOnly,
      silent: silent,
    );
  }

  ///
  /// Other types setter functions
  ///
  Future<bool?> setRealTalk(Map<String, String> realtalk,
      {bool? silent = true, bool? localOnly = true}) async {
    String? realTalkStr;

    try {
      realTalkStr = json.encode(realtalk);
    } catch (e) {
      logger.d(e, time: DateTime.now());
    }

    bool result = await localStorage.setString(
      UserFields.realTalk.name,
      realTalkStr ?? "",
    );

    if (localOnly != true) {
      await _userDocRef?.update({UserFields.realTalk.name: realtalk});
    }

    if (silent != true) {
      notifyListeners();
    }

    return result;
  }
}
