import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Graphic sign-in page layout return `Scaffold` for reusing across Widgets.
///
/// E.g. *page_signin_splash.dart*
///```
/// @override
///  Widget build(context) {
///    return scaffoldSignIn(
///      context,
///      const AssetImage("assets/signin-splash-bg.jpg"),
///      const Padding(
///        padding: EdgeInsets.symmetric(vertical: 32),
///        child: CircularProgressIndicator(
///          strokeCap: StrokeCap.round,
///          color: Colors.white38,
///        ),
///      ),
///    );
///  }
/// ```
Scaffold scaffoldSignIn(
  BuildContext context,
  AssetImage decoration,
  Widget body,
) {
  final l10n = AppLocalizations.of(context);
  final graphicText = Theme.of(context).textTheme.apply(
        displayColor: Colors.white,
        bodyColor: Colors.white,
      );

  return Scaffold(
    body: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: decoration,
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
          body,
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
                      // TODO: Open terms and services page
                    },
                ),
                const TextSpan(text: ' & '),
                TextSpan(
                  text: l10n.privacyPolicy,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // TODO: Open privacy policy page
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
