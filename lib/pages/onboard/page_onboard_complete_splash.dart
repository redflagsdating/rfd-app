// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/mixins/mixin_permissions.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/scaffold_branding.dart';

class PageOnboardCompleteSplash extends StatefulWidget {
  const PageOnboardCompleteSplash({super.key});

  @override
  State<PageOnboardCompleteSplash> createState() =>
      _PageOnboardCompleteSplashState();
}

class _PageOnboardCompleteSplashState extends State<PageOnboardCompleteSplash>
    with MixinPermissions {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await requestNotificationPermissions();

      await context.read<UserProvider>().setOnboarded(true, localOnly: false);

      // Delay to show splash page for UX
      Future.delayed(const Duration(milliseconds: 500), () async {
        Navigator.of(context).pushReplacementNamed("/");
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final displayName =
        Provider.of<UserProvider>(context, listen: false).getDisplayNameCache();

    return ScaffoldBranding(
      hideFooter: true,
      tagLine: l10n!.pgOnboardSplashCompleteTagline(displayName),
      decoration: const AssetImage("assets/onboard-complete-splash-bg.jpg"),
      content: const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: CircularProgressIndicator(
          strokeCap: StrokeCap.round,
          color: Colors.white38,
        ),
      ),
    );
  }
}
