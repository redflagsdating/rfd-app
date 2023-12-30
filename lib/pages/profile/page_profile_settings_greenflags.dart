import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/profile/profile_greenflags.dart';
import 'package:red_flags/widgets/scaffold_page_basic.dart';

class PageProfileSettingsGreenFlags extends StatefulWidget {
  const PageProfileSettingsGreenFlags({super.key, this.title});

  final Widget? title;

  @override
  State<PageProfileSettingsGreenFlags> createState() =>
      _PageProfileSettingsGreenFlagsState();
}

class _PageProfileSettingsGreenFlagsState
    extends State<PageProfileSettingsGreenFlags> {
  List<String>? _initialValue;

  @override
  void initState() {
    _initialValue = context.read<UserProvider>().getGreenFlagsCache();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userProvider = context.read<UserProvider>();

    return ScaffoldPageBasic(
      title: widget.title,
      actions: [
        Semantics(
          button: true,
          label: '${l10n!.save} ${widget.title}',
          child: TextButton(
            child: Text(l10n.save),
            onPressed: () async {
              final greenFlags = userProvider.getGreenFlagsCache();

              if (greenFlags.length < 3) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.pgSelectFlagsErrorText),
                  ),
                );

                return;
              }

              if (!const ListEquality().equals(greenFlags, _initialValue)) {
                final result = await userProvider.setGreenFlags(
                  greenFlags,
                  silent: false,
                  localOnly: false,
                );

                _initialValue = greenFlags;

                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(seconds: 2),
                    content: Text(result == true
                        ? l10n.pgProfileSuccessfulUpdated
                        : l10n.pgProfileFailedUpdated),
                  ),
                );
              }
            },
          ),
        ),
      ],
      content: const ProfileGreenFlags(),
      onBackPressed: () async {
        final greenFlags = userProvider.getGreenFlagsCache();

        // Roll back to initial value if not saved
        if (!const ListEquality().equals(greenFlags, _initialValue)) {
          await userProvider.setGreenFlags(_initialValue!);
        }

        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      },
    );
  }
}
