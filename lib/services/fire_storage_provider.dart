import 'package:firebase_storage/firebase_storage.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:uuid/uuid.dart';

class FireStorageProvider {
  final _uuid = const Uuid();
  late Reference _rootRef;

  FireStorageProvider({required this.userProvider}) {
    _rootRef = FirebaseStorage.instance.ref();
  }
  final UserProvider userProvider;

  Reference get rootRef => _rootRef;

  // Storage references of the current authenticated user id
  Reference get imgStorageRef => _rootRef.child(_getImagesPath());
  Reference get newImgStorageRef =>
      _rootRef.child('${_getImagesPath()}/${_uuid.v4()}');

  // Store references of the provided user id (uid parameter is required)
  Reference imgStorageForRef(String uid) => _rootRef.child(_getImagesPath(uid));
  Reference newImgStorageForRef(String uid) =>
      _rootRef.child('${_getImagesPath(uid)}/${_uuid.v4()}');

  // Internal general functions
  String _getImagesPath([String? uid]) {
    final u = uid ?? userProvider.getIdCache();

    return u.isEmpty ? 'images' : 'images/$u';
  }
}
