import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/profile/profile_realtalk.dart';
import 'package:red_flags/widgets/scaffold_page_basic.dart';

class PageProfileSettingsRealtalk extends StatefulWidget {
  const PageProfileSettingsRealtalk({super.key, this.title});

  final Widget? title;

  @override
  State<PageProfileSettingsRealtalk> createState() =>
      _PageProfileSettingsRealtalkState();
}

class _PageProfileSettingsRealtalkState
    extends State<PageProfileSettingsRealtalk> {
  Map<String, String>? _initialValue;

  @override
  void initState() {
    _initialValue = context.read<UserProvider>().getRealTalkCache();
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
            final realtalk = userProvider.getRealTalkCache();

            if (!mapEquals(realtalk, _initialValue)) {
              final result = await userProvider.setRealTalk(
                realtalk!,
                silent: false,
                localOnly: false,
              );

              _initialValue = realtalk;

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
      content: const ProfileRealTalk(),
      onBackPressed: () async {
        final realtalk = userProvider.getRealTalkCache();

        // Roll back to initial value if not saved
        if (!mapEquals(realtalk, _initialValue)) {
          await userProvider.setRealTalk(_initialValue!);
        }

        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      },
    );
  }
}
