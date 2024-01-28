import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:red_flags/models/qod.dart';
import 'package:red_flags/models/qod_answer.dart';

enum QodStatus {
  unanswered,
  awaiting,
  answered,
}

mixin MixinQod {
  QodStatus getQodStatus(QuerySnapshot<QodAnswerModel>? snapshot) {
    final qodAnswerDocs = snapshot?.docs;

    if (qodAnswerDocs?.length == 2) {
      return QodStatus.answered;
    }

    if (qodAnswerDocs?.length == 1) {
      return QodStatus.awaiting;
    }

    return QodStatus.unanswered;
  }

  QodAnswerModel? getLatestQodAnswer(QuerySnapshot<QodAnswerModel>? snapshot) {
    final qodAnswerDocs = snapshot?.docs;

    if (qodAnswerDocs != null && qodAnswerDocs.isNotEmpty) {
      qodAnswerDocs.sort((a, b) {
        return b.data().answeredAt.difference(a.data().answeredAt).inSeconds;
      });

      return qodAnswerDocs.firstOrNull?.data();
    }

    return null;
  }

  QueryDocumentSnapshot<QodAnswerModel>? getQodAnswerById(
      QuerySnapshot<QodAnswerModel>? snapshot, String uid) {
    final qodAnswerDocs = snapshot?.docs;

    if (qodAnswerDocs != null && qodAnswerDocs.isNotEmpty) {
      return qodAnswerDocs.where((doc) => doc.data().uid == uid).firstOrNull;
    }

    return null;
  }

  // QoD is awaiting their answer (awaiting by you)
  bool isAwaitingByYou(QuerySnapshot<QodAnswerModel>? snapshot, String uid) {
    return getQodStatus(snapshot) == QodStatus.awaiting &&
        getLatestQodAnswer(snapshot)?.uid == uid;
  }

  // QoD is awaiting your answer (awaiting by them)
  bool isAwaitingByThem(QuerySnapshot<QodAnswerModel>? snapshot, String uid) {
    return getQodStatus(snapshot) == QodStatus.awaiting &&
        getLatestQodAnswer(snapshot)?.uid != uid;
  }

  bool isQodNew(QodModel qodModel) {
    return DateTime.now().difference(qodModel.createdAt).inDays < 1;
  }
}
