import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/pages/page_freechat.dart';

class PageOptInDateSplash extends StatefulWidget {
  const PageOptInDateSplash({
    super.key,
    required this.userModel,
    required this.connectionId,
    this.bothOptedIn,
  });

  final UserModel userModel;
  final String connectionId;
  final bool? bothOptedIn;

  @override
  State<PageOptInDateSplash> createState() => _PageOptInDateSplashState();
}

class _PageOptInDateSplashState extends State<PageOptInDateSplash> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isBothOptedIn = widget.bothOptedIn == true;
    final displayName = widget.userModel.displayName ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/opt-in-date-splash-bg.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Semantics(
            readOnly: true,
            label: isBothOptedIn
                ? l10n!.pgOptInDateBothSplashHeadline
                : l10n!.pgOptInDateSplashHeadline,
            child: Text(
              isBothOptedIn
                  ? l10n.pgOptInDateBothSplashHeadline
                  : l10n.pgOptInDateSplashHeadline,
              style: theme.textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Semantics(
            readOnly: true,
            label: isBothOptedIn
                ? l10n.pgOptInDateBothSplashBody(displayName)
                : l10n.pgOptInDateSplashBody(displayName),
            child: Text(
              isBothOptedIn
                  ? l10n.pgOptInDateBothSplashBody(displayName)
                  : l10n.pgOptInDateSplashBody(displayName),
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 80),
          isBothOptedIn
              ? Column(
                  children: [
                    FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                      ),
                      child: Text(l10n.pgOptInDateSplashChatBtn),
                      onPressed: () {
                        Navigator.of(context).pop();

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PageFreeChat(
                              connectionId: widget.connectionId,
                              userModel: widget.userModel,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                        ),
                      ),
                      child: Text(l10n.pgOptInDateSplashContinueBtn),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                )
              : FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                  ),
                  child: Text(l10n.pgOptInDateSplashContinueBtn),
                  onPressed: () => Navigator.of(context).pop(),
                )
        ],
      ),
    );
  }
}
