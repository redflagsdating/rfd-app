import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/auth_provider.dart';
import 'package:red_flags/widgets/mixin_snack_bar.dart';

class PageSignInEmail extends StatefulWidget {
  const PageSignInEmail({super.key});

  @override
  State<PageSignInEmail> createState() => PageSignInEmailState();
}

class PageSignInEmailState extends State<PageSignInEmail>
    with MixinSnackBar, WidgetsBindingObserver {
  late AuthProvider authProvider;
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    authProvider = Provider.of<AuthProvider>(context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    try {
      //
      final subscription = FirebaseDynamicLinks.instance.onLink.listen(
        (event) {
          if (authProvider.status == AuthStatus.pending) {
            authProvider.handleSignIn(event.link.toString()).then(
              (signedIn) {
                if (signedIn &&
                    authProvider.status == AuthStatus.authenticated) {
                  Navigator.popAndPushNamed(context, '/');
                }
              },
            );
          }
        },
      );

      if (authProvider.status == AuthStatus.authenticated) {
        subscription.cancel();
      }
    } catch (e) {
      //
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = authProvider.status == AuthStatus.pending ||
        authProvider.status == AuthStatus.authenticating;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in with Email page'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              readOnly: isDisabled,
              controller: textController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Email address',
              ),
            ),
          ),
          TextButton(
            onPressed: isDisabled
                ? null
                : () {
                    authProvider
                        .sendSignInLinkToEmail(textController.text)
                        .whenComplete(() =>
                            showAuthStatusSnackBar(context, authProvider));
                  },
            child: Text(AppLocalizations.of(context)!.send),
          ),
        ],
      ),
    );
  }
}
