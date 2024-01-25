import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:red_flags/models/connection.dart';

enum QodFields {
  question,
  createdAt,
}

class QodModel {
  const QodModel({
    required this.question,
    required this.createdAt,
  });

  final String question;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      QodFields.question.name: question,
      QodFields.createdAt.name: createdAt,
    };
  }

  QodModel.fromJson(Map<String, dynamic> json)
      : this(
          question: json[QodFields.question.name],
          createdAt: (json[QodFields.createdAt.name]! as Timestamp).toDate(),
        );
}

CollectionReference<QodModel> qodRef(String connectionId) {
  return connectionRef
      .doc(connectionId)
      .collection('qod')
      .withConverter<QodModel>(
        fromFirestore: (snapshots, _) => QodModel.fromJson(snapshots.data()!),
        toFirestore: (qod, _) => qod.toJson(),
      );
}
