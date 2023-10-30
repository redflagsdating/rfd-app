import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

mixin MixinLocalStorage<T extends StatefulWidget> on State<T> {
  late SharedPreferences localStorage;

  @override
  void initState() {
    localStorage = context.read<SharedPreferences>();
    super.initState();
  }

  String? getUserId() {
    return localStorage.getString(UserFields.uid.name);
  }

  String? getEmail() {
    return localStorage.getString(UserFields.email.name);
  }

  String? getFirstName() {
    return localStorage.getString(UserFields.firstName.name);
  }

  Future<bool> setFirstName(String firstName) {
    return localStorage.setString(UserFields.firstName.name, firstName);
  }

  String? getLastName() {
    return localStorage.getString(UserFields.lastName.name);
  }

  Future<bool> setLastName(String lastName) {
    return localStorage.setString(UserFields.lastName.name, lastName);
  }

  String? getDisplayName() {
    return localStorage.getString(UserFields.displayName.name);
  }

  void setDisplayName(String displayName) {
    localStorage.setString(UserFields.displayName.name, displayName);
  }

  String? getGender() {
    return localStorage.getString(UserFields.gender.name);
  }

  Future<bool> setGender(String gender) {
    return localStorage.setString(UserFields.gender.name, gender);
  }

  Future<bool> removeGender() {
    return localStorage.remove(UserFields.gender.name);
  }

  List<String>? getGenderFor() {
    return localStorage.getStringList(UserFields.genderFor.name);
  }

  Future<bool> setGenderFor(List<String> genders) {
    // return localStorage.remove(UserFields.genderFor.name);
    return localStorage.setStringList(
      UserFields.genderFor.name,
      genders.toList(),
    );
  }

  DateTime? getDob() {
    final timestamp = localStorage.getInt(UserFields.dob.name);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  Future<bool> setDob(DateTime dob) {
    return localStorage.setInt(UserFields.dob.name, dob.millisecondsSinceEpoch);
  }

  String? getReside() {
    return localStorage.getString(UserFields.reside.name);
  }

  Future<bool> setReside(String reside) {
    return localStorage.setString(UserFields.reside.name, reside);
  }

  bool? getOnboarded() {
    return localStorage.getBool(UserFields.onboarded.name);
  }

  Future<bool> setOnboarded(bool onboarded) {
    return localStorage.setBool(UserFields.onboarded.name, onboarded);
  }

  bool? getVerified() {
    return localStorage.getBool(UserFields.verified.name);
  }

  Future<bool> setVerified(bool verified) {
    return localStorage.setBool(UserFields.verified.name, verified);
  }

  bool? getVerifySubmitted() {
    return localStorage.getBool(UserFields.verifySubmitted.name);
  }

  Future<bool> setVerifySubmitted(bool verifySubmitted) {
    return localStorage.setBool(
      UserFields.verifySubmitted.name,
      verifySubmitted,
    );
  }
}
