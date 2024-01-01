import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/profile/profile_display_name.dart';
import 'package:red_flags/widgets/scaffold_page_basic.dart';

class PageProfileSettingsDisplayName extends StatefulWidget {
  const PageProfileSettingsDisplayName({super.key, this.title});
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
  late ScaffoldMessengerState _scaffoldMessenger;

  void _setEnabled(bool value) {
    setState(() {
      _enabled = value;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scaffoldMessenger.clearSnackBars();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _scaffoldMessenger = ScaffoldMessenger.of(context);
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
        Semantics(
          button: true,
          label: '${l10n!.save} ${widget.title}',
          child: TextButton(
            child: Text(l10n.save),
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

              _scaffoldMessenger.showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 2),
                  content: Text(result == true
                      ? l10n.pgProfileSuccessfulUpdated
                      : l10n.pgProfileFailedUpdated),
                ),
              );

              _setEnabled(true);
            },
          ),
        ),
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
