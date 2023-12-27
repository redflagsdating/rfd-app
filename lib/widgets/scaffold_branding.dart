import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:red_flags/services/utils.dart';

class ScaffoldBranding extends Scaffold {
  ScaffoldBranding({
    super.key,
    required this.decoration,
    required this.content,
    this.tagLine,
    this.hideFooter,
  }) : super(
          body: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              final graphicText = Theme.of(context).textTheme.apply(
                    displayColor: Colors.white,
                    bodyColor: Colors.white,
                    fontFamily: 'Nunito',
                  );

              return Container(
                width: double.infinity,
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
                            tagLine ?? l10n!.scaffoldBrandingTagLine,
                            style: graphicText.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    content,
                    if (hideFooter != true)
                      SizedBox(
                        width: 320,
                        child: Text.rich(
                          textAlign: TextAlign.center,
                          TextSpan(
                            style: graphicText.bodySmall,
                            text: l10n!.pgSignInFooter,
                            children: [
                              const TextSpan(text: ' '),
                              TextSpan(
                                text: l10n.termOfService,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    await Utils.launchTncWebview();
                                  },
                              ),
                              TextSpan(text: ' ${l10n.and} '),
                              TextSpan(
                                text: l10n.privacyPolicy,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    await Utils.launchPrivacyPolicyWebview();
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );

  final AssetImage decoration;
  final Widget content;
  final String? tagLine;
  final bool? hideFooter;
}
