import 'dart:io';

import 'package:path_provider/path_provider.dart';

mixin MixinFile {
  /// Create a `File` object in the directory [getApplicationDocumentsDirectory]
  /// based on the [relativePath]
  ///
  /// Example:
  /// - `createFile('images/3hVk8keNCAUJ9UmKVh7OqGl13iI3/photo.jpg')`
  Future<File> createFileObject(String relativePath) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final file = File('${appDocDir.path}/$relativePath');

    if (!await file.exists()) {
      await file.create(recursive: true);
    }

    return file;
  }
}
