import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/extensions/firestore_extension.dart';
import 'package:red_flags/mixins/mixin_qod.dart';
import 'package:red_flags/models/qod.dart';
import 'package:red_flags/models/qod_answer.dart';
import 'package:red_flags/services/user_provider.dart';

class LabelQodStatus extends StatefulWidget {
  const LabelQodStatus({
    super.key,
    required this.qodDocRef,
    required this.displayName,
    this.fontSize,
  });

  final DocumentReference<QodModel> qodDocRef;
  final String displayName;
  final double? fontSize;

  @override
  State<LabelQodStatus> createState() => _LabelQodStatusState();
}

class _LabelQodStatusState extends State<LabelQodStatus> with MixinQod {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final userProvider = Provider.of<UserProvider>(context);

    return FutureBuilder(
      future: qodAnswerRef(widget.qodDocRef).getCacheFirst(),
      builder: (context, snapshot) {
        String label = l10n!.labelQodStatusNew;

        final qodSnapshot = snapshot.data;
        final status = getQodStatus(qodSnapshot);
        final latestAnswer = getLatestAnswer(qodSnapshot);
        final yourUid = userProvider.getIdCache();

        if (status == QodStatus.answered) {
          label = latestAnswer?.answeredAt != null
              ? l10n.labelQodStatusAnswered(
                  DateFormat.MMMd().format(latestAnswer!.answeredAt),
                )
              : l10n.unknown;
        } else if (isAwaitingByYou(qodSnapshot, yourUid)) {
          label = l10n.labelQodStatusAwaitingByYou(widget.displayName);
        } else if (isAwaitingByThem(qodSnapshot, yourUid)) {
          label = l10n.labelQodStatusAwaitingByThem(widget.displayName);
        }

        return Text(
          label,
          semanticsLabel: label,
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: widget.fontSize ?? 13,
            fontWeight: FontWeight.w300,
            color: theme.colorScheme.outline,
          ),
        );
      },
    );
  }
}
