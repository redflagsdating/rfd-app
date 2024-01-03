import 'dart:collection';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:logger/logger.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:uuid/uuid.dart';

class FireStorageProvider {
  final _uuid = const Uuid();
  final _defaultCacheManager = DefaultCacheManager();
  final _cachedDownloadUrl = HashSet<String?>();

  late Reference _rootRef;

  FireStorageProvider({required this.logger, required this.userProvider}) {
    _rootRef = FirebaseStorage.instance.ref();
  }
  final Logger logger;
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

  /// A wrapper of Firebase Storage Reference.getDownloadURL() that decorates
  /// with cache mechanism to prevent exhaustively trigger API calls for the
  /// same path
  Future<String> _getDownloadUrl(Reference ref) async {
    final fullPath = Uri.encodeComponent(ref.fullPath);
    String? url = _cachedDownloadUrl.firstWhere(
      (element) => element != null && element.contains(fullPath),
      orElse: () => null,
    );

    url ??= await ref.getDownloadURL();
    // HashSet<String> guarantees uniqueness
    _cachedDownloadUrl.add(url);

    return url;
  }

  // Cache images from Firebase Storage to prevent unnecessary API calls
  Future<String?> cacheImage(String? path) async {
    if (path == null) {
      return null;
    }

    final Reference ref = rootRef.child(path);
    final imageUrl = await _getDownloadUrl(ref);

    // Only fetch image from Firebase Storage if not in the cache
    if ((await _defaultCacheManager.getFileFromCache(imageUrl))?.file == null) {
      final imageBytes = await ref.getData();

      if (imageBytes != null) {
        await _defaultCacheManager.putFile(
          imageUrl,
          imageBytes,
        );
      }
    }

    return imageUrl;
  }

  // Purge images in Firebase storage for delete account scenario mainly
  Future<void> deleteImgStorage([String? uid]) async {
    final ref = uid != null ? imgStorageForRef(uid) : imgStorageRef;
    final files = await ref.listAll();

    try {
      for (var file in files.items) {
        await file.delete();
      }

      logger.d(
        "Successfully erase user storage of images",
        time: DateTime.now(),
      );
    } catch (e) {
      logger.e(e, time: DateTime.now());
    }
  }
}
