enum QodStatus {
  unanswered,
  primaryAnswered,
  secondaryAnswered,
  answered,
}

class QodModel {
  const QodModel({
    required this.question,
    required this.primaryUserId,
    required this.primaryUserDisplayName,
    this.primaryUserPhotoUrl,
    required this.secondaryUserId,
    required this.secondaryDisplayName,
    this.secondaryUserPhotoUrl,
    required this.createdAt,
    this.primaryUserAnswer,
    this.secondaryUserAnswer,
    this.answeredAt,
  });

  final String question;
  final String primaryUserId;
  final String primaryUserDisplayName;
  final String? primaryUserPhotoUrl;
  final String secondaryUserId;
  final String secondaryDisplayName;
  final String? secondaryUserPhotoUrl;
  final DateTime createdAt;
  final String? primaryUserAnswer;
  final String? secondaryUserAnswer;
  final DateTime? answeredAt;

  QodStatus get status =>
      primaryUserAnswer != null && secondaryUserAnswer != null
          ? QodStatus.answered
          : primaryUserAnswer != null
              ? QodStatus.primaryAnswered
              : secondaryUserAnswer != null
                  ? QodStatus.secondaryAnswered
                  : QodStatus.unanswered;

  bool get isNew => DateTime.now().difference(createdAt).inHours < 24;
}
