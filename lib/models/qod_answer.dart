import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:red_flags/models/qod.dart';

enum QodAnswerFields {
  uid,
  answer,
  answeredAt,
}

class QodAnswerModel {
  const QodAnswerModel({
    required this.uid,
    required this.answer,
    required this.answeredAt,
  });

  final String uid;
  final String answer;
  final DateTime answeredAt;

  Map<String, dynamic> toJson() {
    return {
      QodAnswerFields.uid.name: uid,
      QodAnswerFields.answer.name: answer,
      QodAnswerFields.answeredAt.name: answeredAt,
    };
  }

  QodAnswerModel.fromJson(Map<String, dynamic> json)
      : this(
          uid: json[QodAnswerFields.uid.name],
          answer: json[QodAnswerFields.answer.name],
          answeredAt:
              (json[QodAnswerFields.answeredAt.name]! as Timestamp).toDate(),
        );
}

CollectionReference<QodAnswerModel> qodAnswerRef(
    DocumentReference<QodModel> qodDocRef) {
  return qodDocRef.collection('qodAnswer').withConverter<QodAnswerModel>(
        fromFirestore: (snapshots, _) =>
            QodAnswerModel.fromJson(snapshots.data()!),
        toFirestore: (qodAnswer, _) => qodAnswer.toJson(),
      );
}
