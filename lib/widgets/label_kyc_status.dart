import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_idensic_mobile_sdk_plugin/flutter_idensic_mobile_sdk_plugin.dart';

class LabelKycStatus extends StatefulWidget {
  const LabelKycStatus({super.key, this.status});
  final SNSMobileSDKStatus? status;

  @override
  State<LabelKycStatus> createState() => _LabelKycStatusState();
}

class _LabelKycStatusState extends State<LabelKycStatus> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    var color = theme.colorScheme.outlineVariant;
    var icon = Icon(Icons.question_mark_rounded, color: color);
    var label = l10n!.unknown;

    switch (widget.status) {
      case SNSMobileSDKStatus.Approved:
        color = Colors.green;
        icon = Icon(Icons.check, color: color);
        label = l10n.verified;
        break;

      case SNSMobileSDKStatus.Pending:
        color = theme.colorScheme.tertiary;
        icon = Icon(Icons.access_time_filled_rounded, color: color);
        label = l10n.pending;
        break;

      case SNSMobileSDKStatus.FinallyRejected:
      case SNSMobileSDKStatus.TemporarilyDeclined:
        color = theme.colorScheme.error;
        icon = Icon(Icons.cancel, color: color);
        label = l10n.declined;
        break;

      case SNSMobileSDKStatus.Failed:
        color = theme.colorScheme.error;
        icon = Icon(Icons.error, color: color);
        label = l10n.error;
        break;

      default:
        color = theme.colorScheme.secondary;
        icon = Icon(Icons.incomplete_circle, color: color);
        label = l10n.incomplete;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon,
        const SizedBox(width: 2),
        Text(
          label,
          style: theme.textTheme.apply(bodyColor: color).labelLarge,
        ),
      ],
    );
  }
}
