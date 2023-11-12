import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileGreenFlags extends StatefulWidget {
  const ProfileGreenFlags({Key? key}) : super(key: key);

  @override
  State<ProfileGreenFlags> createState() => _ProfileGreenFlagsState();
}

class _ProfileGreenFlagsState extends State<ProfileGreenFlags> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n!.pgGreenFlagsHeadline,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Text(l10n.pgSelectFlagsBody),
      ],
    );
  }
}
