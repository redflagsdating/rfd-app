import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:uuid/uuid.dart';

class FireStorageProvider {
  final _uuid = const Uuid();
  late Reference _rootRef;

  FireStorageProvider({required this.context, required this.userProvider}) {
    _rootRef = FirebaseStorage.instance.ref();
  }

  final BuildContext context;
  final UserProvider userProvider;

  Reference get imgStorageRef => _rootRef.child(getImagesPath());
  Reference get newImgStorageRef =>
      _rootRef.child('${getImagesPath()}/${_uuid.v4()}');

  Reference imgStorageForRef(String uid) => _rootRef.child(getImagesPath(uid));
  Reference newImgStorageForRef(String uid) =>
      _rootRef.child('${getImagesPath(uid)}/${_uuid.v4()}');

  String getImagesPath([String? uid]) {
    final u = uid ?? userProvider.getIdCache() ?? "";

    return u.isEmpty ? 'images' : 'images/$u';
  }
}
