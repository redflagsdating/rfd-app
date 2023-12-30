import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/extensions/list_extension.dart';
import 'package:red_flags/extensions/string_extension.dart';
import 'package:red_flags/models/flag.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/list_flag_choice_chips.dart';
import 'package:red_flags/widgets/text_field_chips.dart';

class ProfileGreenFlags extends StatefulWidget {
  const ProfileGreenFlags({super.key});

  @override
  State<ProfileGreenFlags> createState() => _ProfileGreenFlagsState();
}

class _ProfileGreenFlagsState extends State<ProfileGreenFlags> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          children: [
            Icon(
              Icons.flag_circle_sharp,
              size: 32,
              shadows: [
                Shadow(
                  color: theme.colorScheme.outlineVariant,
                  offset: const Offset(0, 1),
                  blurRadius: 6,
                )
              ],
              color: Colors.green,
            ),
            const SizedBox(width: 4),
            Text(
              l10n!.pgGreenFlagsHeadline,
              style: theme.textTheme.headlineSmall,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(l10n.pgSelectFlagsBody),
        const SizedBox(height: 10),
        ListenableBuilder(
          listenable: userProvider,
          builder: (context, _) {
            final selected = userProvider.getGreenFlagsCache();
            final isEnabled = selected.length < 3;
            final splitMatch = selected.splitMatch(
                (element) => FlagModel.greenFlags.contains(element));

            return Column(
              children: [
                Semantics(
                  textField: true,
                  focusable: true,
                  label: l10n.fieldYourGreenFlagsHintText,
                  child: TextFieldChips(
                    readOnly: !isEnabled,
                    initialChips: splitMatch.unmatched,
                    hintText: l10n.fieldYourGreenFlagsHintText,
                    validator: (value) {
                      // Force to retrieve from cache due to validator context
                      final s = userProvider.getGreenFlagsCache();
                      final isExisted = FlagModel.greenFlags.any((element) =>
                          element.toLowerCase() == value.toLowerCase());
                      final isDuplicated = s.contains(value);

                      if (isExisted || isDuplicated) {
                        return l10n.fieldYourGreenFlagsErrorText;
                      }

                      s.add(value.capitalize());
                      userProvider.setGreenFlags(s, silent: false);

                      return null;
                    },
                    onDeleted: (value) {
                      selected.remove(value);
                      userProvider.setGreenFlags(selected, silent: false);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ListFlagChoiceChips(
                  enabled: isEnabled,
                  labels: FlagModel.greenFlags,
                  selected: splitMatch.matched,
                  onAdded: (value) {
                    selected.add(value);
                    userProvider.setGreenFlags(selected, silent: false);
                  },
                  onDeleted: (value) {
                    selected.remove(value);
                    userProvider.setGreenFlags(selected, silent: false);
                  },
                ),
              ],
            );
          },
        )
      ],
    );
  }
}
