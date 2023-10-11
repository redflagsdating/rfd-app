import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';
import 'package:red_flags/services/auth_provider.dart';
import 'package:red_flags/widgets/dialog_signin_email.dart';
import 'package:red_flags/widgets/scaffold_signin.dart';

class PageSignIn extends StatefulWidget {
  const PageSignIn({
    super.key,
    required this.authProvider,
    required this.logger,
  });

  final AuthProvider authProvider;
  final Logger logger;

  @override
  State<PageSignIn> createState() => _PageSignInState();
}

class _PageSignInState extends State<PageSignIn> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    try {
      final subscription = FirebaseDynamicLinks.instance.onLink.listen(
        (event) {
          if (widget.authProvider.status == AuthStatus.pending) {
            Navigator.pop(context);
            widget.authProvider.handleSignIn(event.link.toString());
          }
        },
      );

      if (widget.authProvider.status == AuthStatus.authenticated) {
        subscription.cancel();
      }
    } catch (e) {
      widget.logger.e(e, time: DateTime.now());
    }
  }

  @override
  Widget build(context) {
    final l10n = AppLocalizations.of(context);

    return scaffoldSignIn(
      context,
      const AssetImage("assets/signin-bg.jpg"),
      Column(
        children: <Widget>[
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
            ),
            onPressed: () {
              widget.authProvider
                  .handleSignIn(SocialAuthProvider.google)
                  .whenComplete(
                () {
                  if (widget.authProvider.message.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(widget.authProvider.message),
                      ),
                    );
                  }
                },
              );
            },
            child: Text(
              l10n!.pgSignInWithBtn("Google"),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
            ),
            onPressed: () {
              widget.authProvider
                  .handleSignIn(SocialAuthProvider.facebook)
                  .whenComplete(
                () {
                  if (widget.authProvider.message.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(widget.authProvider.message),
                      ),
                    );
                  }
                },
              );
            },
            child: Text(
              l10n.pgSignInWithBtn("Facebook"),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
            ),
            onPressed: () => showDialog(
              context: context,
              builder: (context) =>
                  DialogSigninEmail(authProvider: widget.authProvider),
            ),
            child: Text(
              l10n.pgSignInWithBtn(l10n.email),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
