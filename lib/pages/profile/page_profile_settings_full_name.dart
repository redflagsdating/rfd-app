import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/profile/profile_full_name.dart';
import 'package:red_flags/widgets/scaffold_page_basic.dart';

class PageProfileSettingsFullName extends StatefulWidget {
  const PageProfileSettingsFullName({super.key, this.title});
  final Widget? title;

  @override
  State<PageProfileSettingsFullName> createState() =>
      _PageProfileSettingsFullNameState();
}

class _PageProfileSettingsFullNameState
    extends State<PageProfileSettingsFullName> {
  bool _enabled = true;
  final _form = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();

  void _setEnabled(bool value) {
    setState(() {
      _enabled = value;
    });
  }

  List<String> _getFullName() {
    final userProvider = context.read<UserProvider>();
    return [userProvider.getFirstNameCache(), userProvider.getLastNameCache()];
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    final fullName = _getFullName();

    _firstNameCtrl.text = fullName.first;
    _lastNameCtrl.text = fullName.last;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final isSubmitted = userProvider.getVerifySubmittedCache() ?? false;

    return ScaffoldPageBasic(
      title: widget.title,
      // Full name is not allowed to change after KYC is submitted
      actions: isSubmitted
          ? []
          : [
              Semantics(
                button: true,
                label: '${l10n!.save} ${widget.title}',
                child: TextButton(
                  child: Text(l10n.save),
                  onPressed: () async {
                    if (!_form.currentState!.validate()) {
                      return;
                    }

                    final current = _getFullName();
                    final firstName = _firstNameCtrl.text;
                    final lastName = _lastNameCtrl.text;

                    if (current.first == firstName &&
                        current.last == lastName) {
                      return;
                    }

                    _setEnabled(false);

                    // Update local cache only
                    bool result =
                        await userProvider.setFirstName(firstName) ?? false;
                    result &= await userProvider.setLastName(lastName,
                            silent: false) ??
                        false;

                    // Aggregate Firebase update API calls into one
                    await userProvider.userDocRef?.update({
                      UserFields.firstName.name: firstName,
                      UserFields.lastName.name: lastName,
                    });

                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(seconds: 2),
                        content: Text(result
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
        child: ProfileFullName(
          firstNameCtrl: _firstNameCtrl,
          lastNameCtrl: _lastNameCtrl,
          enabled: !isSubmitted && _enabled,
        ),
      ),
      onBackPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
}
