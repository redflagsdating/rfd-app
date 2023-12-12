import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/profile/profile_birthday.dart';
import 'package:red_flags/widgets/scaffold_page_basic.dart';

class PageProfileSettingsAge extends StatefulWidget {
  const PageProfileSettingsAge({super.key, this.title});
  final Widget? title;

  @override
  State<PageProfileSettingsAge> createState() => _PageProfileSettingsAgeState();
}

class _PageProfileSettingsAgeState extends State<PageProfileSettingsAge> {
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
    final dob = context.read<UserProvider>().getDobCache();
    if (dob != null) {
      _controller.text = DateFormat.yMd().format(dob);
    }
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

            final current = userProvider.getDobCache();
            final dob = DateFormat.yMd().parse(_controller.text);

            if (current != null && dob.isAtSameMomentAs(current)) {
              return;
            }

            _setEnabled(false);

            final result = await userProvider.setDob(
              dob,
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
        child: ProfileBirthday(
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
