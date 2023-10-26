import 'package:animations/animations.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/auth_provider.dart';
import 'package:red_flags/services/logger_provider.dart';
import 'package:red_flags/widgets/dialog_signin_email.dart';
import 'package:red_flags/widgets/page_fade_route_builder.dart';
import 'package:red_flags/widgets/page_signin_intro.dart';
import 'package:red_flags/widgets/scaffold_signin.dart';

class PageSignIn extends StatefulWidget {
  final bool? skipIntro;

  const PageSignIn({super.key, this.skipIntro});

  @override
  State<PageSignIn> createState() => _PageSignInState();
}

class _PageSignInState extends State<PageSignIn> with WidgetsBindingObserver {
  late Logger logger;
  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Navigate to first time PageIntro
    if (!(widget.skipIntro ?? false)) {
      // Workaround using Navigator inside initState()
      Future.microtask(
        () => Navigator.of(context).push(
          PageFadeRouteBuilder(
            page: Builder(
              builder: (context) => const PageSignInIntro(),
            ),
          ),
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    logger = Provider.of<LoggerProvider>(context).logger;
    authProvider = Provider.of<AuthProvider>(context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    try {
      final subscription = FirebaseDynamicLinks.instance.onLink.listen(
        (event) {
          if (authProvider.status == AuthStatus.pending) {
            Navigator.pop(context);
            authProvider.handleSignIn(event.link.toString());
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

    return scaffoldSignIn(
      context,
      const AssetImage("assets/signin-bg.jpg"),
      Column(
        children: <Widget>[
          FilledButton(
            key: const Key("page_signin_google"),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
            ),
            onPressed: () {
              authProvider.handleSignIn(SocialAuthProvider.google).whenComplete(
                () {
                  if (authProvider.message.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(authProvider.message),
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
            key: const Key("page_signin_facebook"),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
            ),
            onPressed: () {
              authProvider
                  .handleSignIn(SocialAuthProvider.facebook)
                  .whenComplete(
                () {
                  if (authProvider.message.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(authProvider.message),
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
            key: const Key("page_signin_email"),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
            ),
            onPressed: () => showGeneralDialog(
              context: context,
              pageBuilder: (context, animation, secondaryAnimation) =>
                  DialogSigninEmail(authProvider: authProvider),
              transitionBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeThroughTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  child: child,
                );
              },
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
