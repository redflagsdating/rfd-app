import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:red_flags/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  DocumentReference<UserModel>? _userDocRef;
  DocumentReference<UserModel>? get userDocRef => _userDocRef;

  UserProvider(
      {required this.logger, required this.localStorage, this.mockUsersRef});

  final Logger logger;
  final SharedPreferences localStorage;
  // TODO: Change to Mockito
  final CollectionReference<UserModel>? mockUsersRef;

  CollectionReference<UserModel> _getUsersRef() {
    // Return mock usersRef for testing purpose
    return (mockUsersRef ?? usersRef);
  }

  Future<void> createUser(UserModel user) async {
    final ref = _getUsersRef().doc(user.uid);

    _userDocRef = ref;
    await ref.set(user);
    await updateUserCache(user);

    logger.d('New user (${user.email}) is created', time: DateTime.now());
  }

  Future<UserModel?> getCurrentUser() async {
    return (await _userDocRef?.get())?.data();
  }

  Future<QuerySnapshot<UserModel>> getUserById(String? uid) async {
    return _getUsersRef().where(UserFields.uid.name, isEqualTo: uid).get();
  }

  String? _getStringFieldCache(UserStringFields field) {
    return localStorage.getString(field.name);
  }

  Future<String?> _getStringField(UserStringFields field) async {
    final cached = _getStringFieldCache(field);

    if (cached != null) {
      return Future.value(cached);
    }

    final doc = await _userDocRef?.get();
    final json = doc?.data()?.toJson();

    return json != null ? json[field.name] : null;
  }

  bool? _getBoolFieldCache(UserBoolFields field) {
    return localStorage.getBool(field.name);
  }

  Future<bool?> _getBoolField(UserBoolFields field) async {
    final cached = _getBoolFieldCache(field);

    if (cached != null) {
      return Future.value(cached);
    }

    final doc = await _userDocRef?.get();
    final json = doc?.data()?.toJson();

    return json != null ? json[field.name] : null;
  }

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

  String? getIdCache() {
    return _getStringFieldCache(UserStringFields.uid);
  }

  String? getFirstNameCache() {
    return _getStringFieldCache(UserStringFields.firstName);
  }

  String? getLastNameCache() {
    return _getStringFieldCache(UserStringFields.lastName);
  }

  String? getDisplayNameCache() {
    return _getStringFieldCache(UserStringFields.displayName);
  }

  String? getGenderCache() {
    return _getStringFieldCache(UserStringFields.gender);
  }

  String? getLocalityCache() {
    return _getStringFieldCache(UserStringFields.locality);
  }

  String? getPhotoUrlCache() {
    return _getStringFieldCache(UserStringFields.photoUrl);
  }

  Map<String, String>? getRealTalkCache() {
    final rawData = _getStringFieldCache(UserStringFields.realTalk);

    try {
      final map = (json.decode(rawData!) as Map).cast<String, String>();

      return map;
    } catch (e) {
      logger.d(e, time: DateTime.now());
    }

    return null;
  }

  Future<bool?> getOnboarded() async {
    return await _getBoolField(UserBoolFields.onboarded);
  }

  Future<bool?> getVerified() async {
    return await _getBoolField(UserBoolFields.verified);
  }

  Future<bool?> getVerifySubmitted() async {
    return await _getBoolField(UserBoolFields.verifySubmitted);
  }

  bool? getVerifySubmittedCache() {
    return _getBoolFieldCache(UserBoolFields.verifySubmitted);
  }

  DateTime? getDobCache() {
    final timestamp = localStorage.getInt(UserFields.dob.name);

    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }

    return null;
  }

  Future<DateTime?> getDob() async {
    final cached = getDobCache();

    if (cached != null) {
      return Future.value(cached);
    }

    final doc = await _userDocRef?.get();

    return doc?.data()?.dob;
  }

  List<String>? getGenderForCache() {
    return localStorage.getStringList(UserFields.genderFor.name);
  }

  Future<List<String>?> getGenderFor() async {
    final cached = getGenderForCache();

    if (cached != null) {
      return Future.value(cached);
    }

    final doc = await _userDocRef?.get();

    return doc?.data()?.genderFor;
  }

  Future<bool?> _setStringField(UserStringFields field, String value,
      {bool? silent = true, bool? localOnly = true}) async {
    final result = await localStorage.setString(field.name, value);

    if (localOnly != true) {
      await _userDocRef?.update({field.name: value});
    }

    if (silent != true) {
      notifyListeners();
    }

    return result;
  }

  Future<bool?> setId(String value, {bool? silent, bool? localOnly}) {
    return _setStringField(UserStringFields.uid, value,
        silent: silent, localOnly: localOnly);
  }

  Future<bool?> setEmail(String value, {bool? silent, bool? localOnly}) {
    return _setStringField(UserStringFields.email, value,
        silent: silent, localOnly: localOnly);
  }

  Future<bool?> setFirstName(String value, {bool? silent, bool? localOnly}) {
    return _setStringField(UserStringFields.firstName, value,
        silent: silent, localOnly: localOnly);
  }

  Future<bool?> setLastName(String value, {bool? silent, bool? localOnly}) {
    return _setStringField(UserStringFields.lastName, value,
        silent: silent, localOnly: localOnly);
  }

  Future<bool?> setDisplayName(String value, {bool? silent, bool? localOnly}) {
    return _setStringField(UserStringFields.displayName, value,
        silent: silent, localOnly: localOnly);
  }

  Future<bool?> setPhotoUrl(String value, {bool? silent, bool? localOnly}) {
    return _setStringField(UserStringFields.photoUrl, value,
        silent: silent, localOnly: localOnly);
  }

  Future<bool?> setGender(String value, {bool? silent, bool? localOnly}) {
    return _setStringField(UserStringFields.gender, value,
        silent: silent, localOnly: localOnly);
  }

  Future<bool?> setLocality(String value, {bool? silent, bool? localOnly}) {
    return _setStringField(UserStringFields.locality, value,
        silent: silent, localOnly: localOnly);
  }

  Future<bool?> setDob(DateTime dob, {bool? silent, bool? localOnly}) async {
    final result =
        localStorage.setInt(UserFields.dob.name, dob.millisecondsSinceEpoch);

    if (localOnly != true) {
      await _userDocRef?.update({UserFields.dob.name: dob});
    }

    if (silent != true) {
      notifyListeners();
    }

    return result;
  }

  Future<bool?> setGenderFor(List<String> genders,
      {bool? silent, bool? localOnly}) async {
    final result = localStorage.setStringList(
      UserFields.genderFor.name,
      genders.toList(),
    );

    if (localOnly != true) {
      await _userDocRef?.update({UserFields.genderFor.name: genders.toList()});
    }

    if (silent != true) {
      notifyListeners();
    }

    return result;
  }

  Future<bool?> setRealTalk(Map<String, String> realtalk,
      {bool? silent, bool? localOnly}) async {
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
    // Init _userDocRef if not existed yet
    _userDocRef ??= _getUsersRef().doc(user.uid);

    final dob = user.dob;

    await setId(user.uid, localOnly: true, silent: true);
    await setEmail(user.email, localOnly: true, silent: true);
    await setFirstName(user.firstName ?? "", localOnly: true, silent: true);
    await setLastName(user.lastName ?? "", localOnly: true, silent: true);
    await setDisplayName(user.displayName ?? "", localOnly: true, silent: true);
    await setGender(user.gender ?? "", localOnly: true, silent: true);
    await setLocality(user.locality ?? "", localOnly: true, silent: true);
    await setPhotoUrl(user.photoUrl ?? "", localOnly: true, silent: true);
    await setGenderFor(user.genderFor ?? [], localOnly: true, silent: true);
    await setRealTalk(user.realTalk ?? {}, localOnly: true, silent: true);

    if (dob != null) {
      await setDob(dob, localOnly: true, silent: true);
    }

    await localStorage.setBool(
      UserFields.onboarded.name,
      user.onboarded,
    );
    await localStorage.setBool(UserFields.verified.name, user.verified);
    await localStorage.setBool(
      UserFields.verifySubmitted.name,
      user.verifySubmitted,
    );

    logger.d(
      'Successfully update cached user (${user.email}) in local storage',
      time: DateTime.now(),
    );
  }
}
