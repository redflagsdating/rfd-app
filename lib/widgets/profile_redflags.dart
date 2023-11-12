import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileRedFlags extends StatefulWidget {
  const ProfileRedFlags({Key? key}) : super(key: key);

  @override
  State<ProfileRedFlags> createState() => _ProfileRedFlagsState();
}

class _ProfileRedFlagsState extends State<ProfileRedFlags> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n!.pgRedFlagsHeadline,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Text(l10n.pgSelectFlagsBody),
      ],
    );
  }
}
