import 'package:cloud_firestore/cloud_firestore.dart';

extension FirestoreDocumentExtension<T> on DocumentReference<T> {
  /// An extension to support get from cache first and fallback to server to
  /// prevent frequent Firestore API calls
  /// https://firebase.google.com/docs/firestore/query-data/get-data#source_options
  Future<DocumentSnapshot<T>> getCacheFirst() async {
    try {
      DocumentSnapshot<T> snapshot = await get(const GetOptions(
        source: Source.cache,
      ));

      if (!snapshot.exists) {
        return get(const GetOptions(source: Source.server));
      }

      return snapshot;
    } catch (_) {
      return get(const GetOptions(source: Source.server));
    }
  }
}

extension FirestoreQueryExtension<T> on Query<T> {
  /// An extension to support get from cache first and fallback to server to
  /// prevent frequent Firestore API calls
  /// https://firebase.google.com/docs/firestore/query-data/get-data#source_options
  Future<QuerySnapshot<T>> getCacheFirst() async {
    try {
      QuerySnapshot<T> snapshot = await get(const GetOptions(
        source: Source.cache,
      ));

      if (snapshot.docs.isEmpty) {
        return get(const GetOptions(source: Source.server));
      }

      return snapshot;
    } catch (_) {
      return get(const GetOptions(source: Source.server));
    }
  }
}
