import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/models/flag.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/chip_flags.dart';

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
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n!.pgGreenFlagsHeadline,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Text(l10n.pgSelectFlagsBody),
        const SizedBox(height: 20),
        ChipFlags(
          flags: FlagModel.greenFlags,
          initialSelected: userProvider.getGreenFlagsCache(),
          onSelected: (selected) {
            userProvider.setGreenFlags(selected);
          },
        )
      ],
    );
  }
}
