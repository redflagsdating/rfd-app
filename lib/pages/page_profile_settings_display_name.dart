import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/profile/profile_display_name.dart';
import 'package:red_flags/widgets/scaffold_page_basic.dart';

class PageProfileSettingsDisplayName extends StatefulWidget {
  const PageProfileSettingsDisplayName({Key? key, this.title})
      : super(key: key);
  final Widget? title;

  @override
  State<PageProfileSettingsDisplayName> createState() =>
      _PageProfileSettingsDisplayNameState();
}

class _PageProfileSettingsDisplayNameState
    extends State<PageProfileSettingsDisplayName> {
  bool _enabled = true;
  final _form = GlobalKey<FormState>();
  final _controller = TextEditingController();

  void _setEnabled(bool value) {
    setState(() {
      _enabled = value;
    });
  }

  @override
  void didChangeDependencies() {
    _controller.text = context.read<UserProvider>().getDisplayNameCache();
    super.didChangeDependencies();
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
            if (!_form.currentState!.validate()) {
              return;
            }

            final current = userProvider.getDisplayNameCache();
            final displayName = _controller.text;

            if (current == displayName) {
              return;
            }

            _setEnabled(false);

            final result = await userProvider.setDisplayName(
              displayName,
              localOnly: false,
              silent: false,
            );

            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 2),
                content: Text(result == true
                    ? l10n.pgProfileSuccessfulUpdated
                    : l10n.pgProfileFailedUpdated),
              ),
            );

            _setEnabled(true);
          },
        )
      ],
      content: Form(
        key: _form,
        child: ProfileDisplayName(
          controller: _controller,
          enabled: _enabled,
        ),
      ),
      onBackPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
}
