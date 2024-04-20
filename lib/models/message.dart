import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:red_flags/models/connection.dart';

enum MessageFields {
  uid,
  type,
  content,
  createdAt,
}

enum MessageType {
  text,
  image,
}

class MessageModel {
  const MessageModel({
    required this.uid,
    required this.createdAt,
    this.type,
    this.content,
  });

  final String uid;
  final String? content;
  final MessageType? type;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      MessageFields.uid.name: uid,
      MessageFields.type.name: type?.name,
      MessageFields.content.name: content,
      MessageFields.createdAt.name: createdAt,
    };
  }

  MessageModel.fromJson(Map<String, dynamic> json)
      : this(
          uid: json[MessageFields.uid.name]!,
          type: MessageType.values.firstWhere(
            (element) => element.name == json[MessageFields.type.name],
            orElse: () => MessageType.text,
          ),
          content: json[MessageFields.content.name],
          createdAt:
              (json[MessageFields.createdAt.name]! as Timestamp).toDate(),
        );
}

CollectionReference<MessageModel> messageRef(String connectionId) {
  return connectionRef
      .doc(connectionId)
      .collection('message')
      .withConverter<MessageModel>(
        fromFirestore: (snapshots, _) =>
            MessageModel.fromJson(snapshots.data()!),
        toFirestore: (message, _) => message.toJson(),
      );
}
