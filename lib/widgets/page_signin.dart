import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/auth_provider.dart';
import 'package:red_flags/widgets/mixin_snack_bar.dart';

class PageSignIn extends StatefulWidget {
  const PageSignIn({super.key});

  @override
  State<PageSignIn> createState() => PageSignInState();
}

class PageSignInState extends State<PageSignIn>
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
      final subscription = FirebaseDynamicLinks.instance.onLink.listen(
        (event) {
          if (authProvider.status == AuthStatus.pending) {
            authProvider.handleSignIn(event.link.toString()).then(
              (signedIn) {
                if (signedIn) {
                  // The logic relies on Timer() delay of AuthStatus change
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.pushNamed(context, '/');
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
      // TODO
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = [AuthStatus.pending, AuthStatus.authenticating]
        .contains(authProvider.status);

    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyPageHome object that was created by
        // the App.build method, and use it to set our AppBar title.
        title: const Text('Sign in page'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: TextButton(
              onPressed: () {
                authProvider
                    .handleSignIn(SocialAuthProvider.google)
                    .whenComplete(
                        () => showAuthStatusSnackBar(context, authProvider));
              },
              child: const Text('Sign in with Google'),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {
                authProvider
                    .handleSignIn(SocialAuthProvider.facebook)
                    .whenComplete(
                        () => showAuthStatusSnackBar(context, authProvider));
              },
              child: const Text('Sign in with Facebook'),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => Dialog.fullscreen(
                  child: Column(
                    children: <Widget>[
                      const Align(
                        alignment: Alignment.topLeft,
                        child: CloseButton(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 40,
                          top: 200,
                          left: 24,
                          right: 24,
                        ),
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
                                    .whenComplete(() => showAuthStatusSnackBar(
                                        context, authProvider));
                              },
                        child: Text(AppLocalizations.of(context)!.send),
                      ),
                    ],
                  ),
                ),
              ),
              child: const Text('Sign in with Email'),
            ),
          ),
        ],
      ),
    );
  }
}
