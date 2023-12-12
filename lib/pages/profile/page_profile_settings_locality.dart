import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/profile/profile_locality.dart';
import 'package:red_flags/widgets/scaffold_page_basic.dart';

class PageProfileSettingsLocality extends StatefulWidget {
  const PageProfileSettingsLocality({super.key, this.title});
  final Widget? title;

  @override
  State<PageProfileSettingsLocality> createState() =>
      _PageProfileSettingsLocalityState();
}

class _PageProfileSettingsLocalityState
    extends State<PageProfileSettingsLocality> {
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
    _controller.text = Provider.of<UserProvider>(context).getLocalityCache();
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

            final current = userProvider.getLocalityCache();
            final locality = _controller.text;

            if (current == locality) {
              return;
            }

            _setEnabled(false);

            final result = await userProvider.setLocality(
              locality,
              localOnly: false,
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
        child: ProfileLocality(enabled: _enabled, controller: _controller),
      ),
      onBackPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
}
