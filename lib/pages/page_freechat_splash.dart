import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PageFreeChatSplash extends StatefulWidget {
  const PageFreeChatSplash({
    super.key,
    required this.displayName,
  });

  final String displayName;

  @override
  State<PageFreeChatSplash> createState() => _PageFreeChatSplashState();
}

class _PageFreeChatSplashState extends State<PageFreeChatSplash> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/freechat-splash-bg.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Semantics(
            readOnly: true,
            label: l10n!.pgFreeChatSplashHeadline,
            child: Text(
              l10n.pgFreeChatSplashHeadline,
              style: theme.textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Semantics(
            readOnly: true,
            label: l10n.pgFreeChatSplashBody(widget.displayName),
            child: Text(
              l10n.pgFreeChatSplashBody(widget.displayName),
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 80),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
            ),
            child: Text(l10n.pgFreeChatSplashBtn),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
