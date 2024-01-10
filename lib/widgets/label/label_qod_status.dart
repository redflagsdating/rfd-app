import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:red_flags/models/qod.dart';

class LabelQodStatus extends StatefulWidget {
  const LabelQodStatus({super.key, required this.qod, this.fontSize});
  final QodModel qod;
  final double? fontSize;

  @override
  State<LabelQodStatus> createState() => _LabelQodStatusState();
}

class _LabelQodStatusState extends State<LabelQodStatus> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final answeredAt = widget.qod.answeredAt;
    final label = widget.qod.status == QodStatus.answered
        ? l10n!.labelQodStatusAllAnswered(
            answeredAt != null
                ? DateFormat.MMMd().format(answeredAt)
                : l10n.unknown,
          )
        : widget.qod.status == QodStatus.primaryAnswered
            ? l10n!.labelQodStatusOursAnswered(widget.qod.secondaryDisplayName)
            : widget.qod.status == QodStatus.secondaryAnswered
                ? l10n!.labelQodStatusTheirsAnswered(
                    widget.qod.primaryUserDisplayName)
                : l10n!.labelQodStatusNew;

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
  }
}
