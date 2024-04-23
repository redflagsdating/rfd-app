import 'package:cloud_firestore/cloud_firestore.dart';

enum ConnectionStatus {
  connected,
  disconnected,
}

enum ConnectionFields {
  uids,
  status,
  // Opted in for a data (Go on a date)
  optedInUids,
}

class ConnectionModel {
  const ConnectionModel({
    required this.uids,
    required this.status,
    this.optedInUids,
  });

  final List<String> uids;
  final ConnectionStatus status;
  final List<String>? optedInUids;

  Map<String, dynamic> toJson() {
    return {
      ConnectionFields.uids.name: uids,
      ConnectionFields.status.name: status.name,
      ConnectionFields.optedInUids.name: optedInUids,
    };
  }

  ConnectionModel.fromJson(Map<String, dynamic> json)
      : this(
          uids: json[ConnectionFields.uids.name]?.cast<String>(),
          status: ConnectionStatus.values.firstWhere(
            (value) => value.name == json[ConnectionFields.status.name],
          ),
          optedInUids: json[ConnectionFields.optedInUids.name]?.cast<String>(),
        );
}

final connectionRef = FirebaseFirestore.instance
    .collection('connection')
    .withConverter<ConnectionModel>(
      fromFirestore: (snapshots, _) =>
          ConnectionModel.fromJson(snapshots.data()!),
      toFirestore: (connection, _) => connection.toJson(),
    );
