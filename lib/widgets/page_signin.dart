import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/auth_provider.dart';
import 'package:red_flags/services/logger_provider.dart';
import 'package:red_flags/widgets/dialog_signin_email.dart';
import 'package:red_flags/widgets/mixin_snack_bar.dart';

class PageSignIn extends StatefulWidget {
  const PageSignIn({super.key});

  @override
  State<PageSignIn> createState() => PageSignInState();
}

class PageSignInState extends State<PageSignIn>
    with MixinSnackBar, WidgetsBindingObserver {
  late Logger logger;
  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    authProvider = Provider.of<AuthProvider>(context);
    logger = Provider.of<LoggerProvider>(context).logger;
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
                  // Navigator.popUntil(context, (route) => route.isFirst);
                  // Navigator.pushNamed(context, '/');
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
      logger.e(e, time: DateTime.now());
    }
  }

  @override
  Widget build(context) {
    final l10n = AppLocalizations.of(context);
    final graphicText = Theme.of(context).textTheme.apply(
          displayColor: Colors.white,
          bodyColor: Colors.white,
        );

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/signin-background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    "assets/rf-logo-white.png",
                    width: 160,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    l10n!.pgSignInTagLine,
                    style: graphicText.headlineSmall,
                  ),
                ],
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
              ),
              onPressed: () {
                authProvider
                    .handleSignIn(SocialAuthProvider.google)
                    .whenComplete(
                        () => showAuthStatusSnackBar(context, authProvider));
              },
              child: Text(
                l10n.pgSignInWithBtn("Google"),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
              ),
              onPressed: () {
                authProvider
                    .handleSignIn(SocialAuthProvider.facebook)
                    .whenComplete(
                        () => showAuthStatusSnackBar(context, authProvider));
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
                builder: (context) => const DialogSigninEmail(),
              ),
              child: Text(
                l10n.pgSignInWithBtn(l10n.email),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                style: graphicText.bodyMedium,
                text: l10n.pgSignInFooter,
                children: [
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: l10n.termOfService,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // TODO
                        showInfoSnackBar(
                          context,
                          "TODO: Open Terms of Service agreement",
                        );
                      },
                  ),
                  const TextSpan(text: ' & '),
                  TextSpan(
                    text: l10n.privacyPolicy,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // TODO
                        showInfoSnackBar(
                          context,
                          "TODO: Open Privacy policy",
                        );
                      },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
