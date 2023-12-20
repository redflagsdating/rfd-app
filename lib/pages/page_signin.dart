import 'dart:async';

import 'package:animations/animations.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/extensions/string_extension.dart';
import 'package:red_flags/pages/page_signin_intro.dart';
import 'package:red_flags/services/auth_provider.dart';
import 'package:red_flags/services/logger_provider.dart';
import 'package:red_flags/widgets/animation/page_fade_route_builder.dart';
import 'package:red_flags/widgets/dialog_signin_email.dart';
import 'package:red_flags/widgets/scaffold_branding.dart';

class PageSignIn extends StatefulWidget {
  final bool? showIntro;

  const PageSignIn({super.key, this.showIntro});

  @override
  State<PageSignIn> createState() => _PageSignInState();
}

class _PageSignInState extends State<PageSignIn> with WidgetsBindingObserver {
  bool _showDialogSigninEmail = false;
  late Logger _logger;
  late AuthProvider _authProvider;
  late StreamSubscription<PendingDynamicLinkData> _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Navigate to first time PageIntro
    if (widget.showIntro == true) {
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
    _logger = Provider.of<LoggerProvider>(context).logger;
    _authProvider = Provider.of<AuthProvider>(context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    try {
      _subscription = FirebaseDynamicLinks.instance.onLink.listen(
        (event) async {
          if (_authProvider.isPending()) {
            Navigator.pop(context);
            await _authProvider.handleSignIn(event.link.toString());
            await _subscription.cancel();
          }
        },
      );
    } catch (e) {
      _logger.e(e, time: DateTime.now());
    }
  }

  @override
  Widget build(context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final authProvider = context.read<AuthProvider>();
    final loggedInProvider = authProvider.getLastLoggedInAuthProvider();

    return ScaffoldBranding(
      decoration: const AssetImage("assets/signin-bg.jpg"),
      content: Column(
        children: <Widget>[
          if (loggedInProvider != null && !_showDialogSigninEmail)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
              child: Text(
                l10n!.pgSignInWithHintText(
                  l10n.pgSignInWithBtn(loggedInProvider.name.capitalize()),
                ),
                textAlign: TextAlign.center,
                style: theme.textTheme
                    .apply(
                      displayColor: Colors.white,
                    )
                    .bodySmall,
              ),
            ),
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
            onPressed: () {
              setState(() {
                _showDialogSigninEmail = true;
              });

              showGeneralDialog(
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
              ).whenComplete(() {
                // A workaround to prevent overflow
                Future.delayed(const Duration(milliseconds: 100), () {
                  setState(() {
                    _showDialogSigninEmail = false;
                  });
                });
              });
            },
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
