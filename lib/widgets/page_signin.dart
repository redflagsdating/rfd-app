import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/gestures.dart';
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
    authProvider = Provider.of<AuthProvider>(context);
    super.didChangeDependencies();
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
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme.apply(
          displayColor: Colors.white,
          bodyColor: Colors.white,
        );
    final isDisabled = [AuthStatus.pending, AuthStatus.authenticating]
        .contains(authProvider.status);

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(
          bottom: 48,
          top: 140,
          left: 24,
          right: 24,
        ),
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/signin-background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            Image.asset(
              "assets/rf-logo-white.png",
              width: 160,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Text(
                l10n!.pageSignInTagLine,
                style: textTheme.headlineSmall,
              ),
            ),
            FilledButton(
              onPressed: () {
                authProvider
                    .handleSignIn(SocialAuthProvider.google)
                    .whenComplete(
                        () => showAuthStatusSnackBar(context, authProvider));
              },
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  l10n.pageSignInWithBtn("Google"),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                authProvider
                    .handleSignIn(SocialAuthProvider.facebook)
                    .whenComplete(
                        () => showAuthStatusSnackBar(context, authProvider));
              },
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  l10n.pageSignInWithBtn("Facebook"),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
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
                          decoration: InputDecoration(
                            border: const UnderlineInputBorder(),
                            labelText: l10n.email,
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
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  l10n.pageSignInWithBtn(l10n.email),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                style: textTheme.labelLarge,
                text: l10n.pageSignInFooter,
                children: [
                  const TextSpan(text: ' '),
                  TextSpan(
                      text: l10n.termOfService,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // TODO
                          showInfoSnackBar(
                            context,
                            "TODO: Open Terms of Service agreement",
                          );
                        }),
                  const TextSpan(text: ' & '),
                  TextSpan(
                      text: l10n.privacyPolicy,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // TODO
                          showInfoSnackBar(
                            context,
                            "TODO: Open Privacy policy",
                          );
                        }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
