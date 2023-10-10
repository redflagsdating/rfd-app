import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/auth_provider.dart';
import 'package:red_flags/widgets/mixin_snack_bar.dart';

class DialogSigninEmail extends StatefulWidget {
  const DialogSigninEmail({super.key});

  @override
  State<DialogSigninEmail> createState() => DialogSigninEmailState();
}

class DialogSigninEmailState extends State<DialogSigninEmail>
    with MixinSnackBar {
  final _emailForm = GlobalKey<FormState>();
  final _textCtrl = TextEditingController();

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    final l10n = AppLocalizations.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final enabled = authProvider.status != AuthStatus.authenticating;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _emailForm,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.email,
                size: 28,
              ),
              Text(
                l10n!.pgSignInEmailTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.pgSignInEmailSubTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 38),
              TextFormField(
                enabled: enabled,
                controller: _textCtrl,
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  labelText: l10n.pgSignInEmailLabel,
                  hintText: "your@email.com",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pgSignInEmailEmpty;
                  }

                  if (!EmailValidator.validate(value)) {
                    return l10n.pgSignInEmailInvalid;
                  }

                  return null;
                },
              ),
              const SizedBox(height: 30),
              FilledButton(
                onPressed: !enabled
                    ? null
                    : () {
                        if (_emailForm.currentState!.validate()) {
                          final email = _textCtrl.text;

                          authProvider
                              .sendSignInLinkToEmail(email)
                              .whenComplete(
                            () {
                              showSuccessSnackBar(
                                  context, l10n.pgSignInEmailSent(email));
                              Navigator.pop(context);
                            },
                          );
                        }
                      },
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    AppLocalizations.of(context)!.pgSignInEmailSendBtn,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
