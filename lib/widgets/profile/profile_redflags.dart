import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/models/flag.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/list_flag_chips.dart';

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
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n!.pgRedFlagsHeadline,
              style: theme.textTheme.headlineSmall,
            ),
            Icon(
              Icons.flag_rounded,
              size: 32,
              shadows: [
                Shadow(
                  color: theme.colorScheme.outlineVariant,
                  offset: const Offset(0, 1),
                  blurRadius: 6,
                )
              ],
              color: theme.colorScheme.primary,
            )
          ],
        ),
        const SizedBox(height: 10),
        Text(l10n.pgSelectFlagsBody),
        const SizedBox(height: 20),
        ListFlagChips(
          labels: FlagModel.redFlags,
          initialSelected: userProvider.getRedFlagsCache(),
          onSelected: (selected) {
            userProvider.setRedFlags(selected);
          },
        )
      ],
    );
  }
}
