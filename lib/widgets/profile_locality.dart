import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:red_flags/widgets/text_form_field_location.dart';

class ProfileLocality extends StatefulWidget {
  const ProfileLocality({
    Key? key,
    this.enabled,
    required this.controller,
  }) : super(key: key);

  final bool? enabled;
  final TextEditingController controller;

  @override
  State<ProfileLocality> createState() => _ProfileLocalityState();
}

class _ProfileLocalityState extends State<ProfileLocality> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n!.pgOnboardLocalityHeadline,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Text(l10n.pgOnboardLocalityBody),
        const SizedBox(height: 48),
        TextFormFieldLocation(
          enabled: widget.enabled,
          controller: widget.controller,
        )
      ],
    );
  }
}
