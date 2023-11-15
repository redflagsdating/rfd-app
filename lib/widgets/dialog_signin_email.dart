import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:red_flags/services/auth_provider.dart';

class DialogSigninEmail extends StatefulWidget {
  const DialogSigninEmail({super.key, required this.authProvider});
  final AuthProvider authProvider;

  @override
  State<DialogSigninEmail> createState() => _DialogSigninEmailState();
}

class _DialogSigninEmailState extends State<DialogSigninEmail> {
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
    final enabled = widget.authProvider.status != AuthStatus.initializing;

    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(key: Key("dialog_email_signin_close")),
      ),
      body: Dialog.fullscreen(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Form(
              key: _emailForm,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      key: const Key("dialog_email_signin_title"),
                      l10n!.pgSignInEmailTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 38),
                    TextFormField(
                      key: const Key("dialog_email_signin_input"),
                      enabled: enabled,
                      autofocus: true,
                      controller: _textCtrl,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
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
                      key: const Key("dialog_email_signin_send"),
                      onPressed: !enabled
                          ? null
                          : () {
                              if (_emailForm.currentState!.validate()) {
                                widget.authProvider
                                    .sendSignInLinkToEmail(_textCtrl.text)
                                    .whenComplete(
                                  () {
                                    if (widget.authProvider.status ==
                                        AuthStatus.pending) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          duration: const Duration(seconds: 8),
                                          action: SnackBarAction(
                                            label: l10n.resend,
                                            onPressed: () {
                                              if (enabled) {
                                                widget.authProvider
                                                    .sendSignInLinkToEmail(
                                                        _textCtrl.text);
                                              }
                                            },
                                          ),
                                          content: Text(l10n.pgSignInEmailSent),
                                        ),
                                      );
                                    }
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
          ),
        ),
      ),
    );
  }
}
