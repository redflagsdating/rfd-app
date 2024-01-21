import 'package:cloud_firestore/cloud_firestore.dart';

enum ConnectionStatus {
  connected,
  disconnected,
}

enum ConnectionFields {
  uids,
  status,
}

class ConnectionModel {
  const ConnectionModel({
    required this.uids,
    required this.status,
  });

  final List<String> uids;
  final ConnectionStatus status;

  Map<String, dynamic> toJson() {
    return {
      ConnectionFields.uids.name: uids,
      ConnectionFields.status.name: status.name,
    };
  }

  ConnectionModel.fromJson(Map<String, dynamic> json)
      : this(
          uids: json[ConnectionFields.uids.name]?.cast<String>(),
          status: ConnectionStatus.values.firstWhere(
            (value) => value.name == json[ConnectionFields.status.name],
          ),
        );
}

final connectionRef = FirebaseFirestore.instance
    .collection('connection')
    .withConverter<ConnectionModel>(
      fromFirestore: (snapshots, _) =>
          ConnectionModel.fromJson(snapshots.data()!),
      toFirestore: (user, _) => user.toJson(),
    );
