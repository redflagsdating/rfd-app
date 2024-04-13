import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/extensions/firestore_extension.dart';
import 'package:red_flags/models/connection.dart';
import 'package:red_flags/models/qod.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/card/card_connection_content.dart';
import 'package:red_flags/widgets/card/card_connection_error.dart';
import 'package:red_flags/widgets/card/card_connection_placeholder.dart';

class CardConnection extends StatefulWidget {
  const CardConnection({
    super.key,
    required this.id,
  });

  final String id;

  @override
  State<CardConnection> createState() => _CardConnectionState();
}

class _CardConnectionState extends State<CardConnection> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final connectionDocRef = connectionRef.doc(widget.id);

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 280,
        minHeight: 280,
        maxWidth: (MediaQuery.of(context).size.width * 0.8).ceil().toDouble(),
        maxHeight: (MediaQuery.of(context).size.height * 0.7).ceil().toDouble(),
      ),
      // Fetch connection document data
      child: FutureBuilder(
        future: connectionDocRef.getCacheFirst(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CardConnectionPlaceholder();
          }

          final connection = snapshot.data?.data();

          // Connection document data is empty
          if (connection == null) {
            final message = snapshot.hasError
                ? snapshot.error.toString()
                : l10n!.cardConnectionEmptyData(widget.id);

            return CardConnectionError(message: message);
          }

          final uidMyself = userProvider.getIdCache();
          final uid = connection.uids.firstWhere(
            (uid) => uid != uidMyself,
          );

          return FutureBuilder(
            /// Exception use case not using userProvider.getUserModelById
            /// mainly to use getCacheFirst() extension function for server
            /// fallback.
            future: userProvider.usersRef
                .where(UserFields.uid.name, isEqualTo: uid)
                .getCacheFirst(),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs;
              final isEmpty = docs == null || docs.isEmpty;
              final message = snapshot.hasError
                  ? snapshot.error.toString()
                  : l10n!.cardConnectionEmptyUserData(uid);

              return !snapshot.hasData
                  ? const CardConnectionPlaceholder()
                  : isEmpty
                      ? CardConnectionError(message: message)
                      : CardConnectionContent(
                          userModel: docs.first.data(),
                          qodCollectionRef: qodRef(widget.id),
                        );
            },
          );
        },
      ),
    );
  }
}
