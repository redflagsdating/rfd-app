import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/profile/profile_redflags.dart';
import 'package:red_flags/widgets/scaffold_page_basic.dart';

class PageProfileSettingsRedFlags extends StatefulWidget {
  const PageProfileSettingsRedFlags({Key? key, this.title}) : super(key: key);

  final Widget? title;

  @override
  State<PageProfileSettingsRedFlags> createState() =>
      _PageProfileSettingsRedFlagsState();
}

class _PageProfileSettingsRedFlagsState
    extends State<PageProfileSettingsRedFlags> {
  List<String>? _initialValue;

  @override
  void initState() {
    _initialValue = context.read<UserProvider>().getRedFlagsCache();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userProvider = context.read<UserProvider>();

    return ScaffoldPageBasic(
      title: widget.title,
      actions: [
        TextButton(
          child: Text(l10n!.save),
          onPressed: () async {
            final redflags = userProvider.getRedFlagsCache();

            if (!const ListEquality().equals(redflags, _initialValue)) {
              final result = await userProvider.setRedFlags(
                redflags,
                silent: false,
                localOnly: false,
              );

              _initialValue = redflags;

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
      ],
      content: const ProfileRedFlags(),
      onBackPressed: () async {
        final redflags = userProvider.getRedFlagsCache();

        // Roll back to initial value if not saved
        if (!const ListEquality().equals(redflags, _initialValue)) {
          await userProvider.setRedFlags(_initialValue!);
        }

        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      },
    );
  }
}
