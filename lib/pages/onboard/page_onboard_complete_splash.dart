// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/mixins/mixin_api.dart';
import 'package:red_flags/services/logger_provider.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/scaffold_branding.dart';

class PageOnboardCompleteSplash extends StatefulWidget {
  const PageOnboardCompleteSplash({super.key});

  @override
  State<PageOnboardCompleteSplash> createState() =>
      _PageOnboardCompleteSplashState();
}

class _PageOnboardCompleteSplashState extends State<PageOnboardCompleteSplash>
    with MixinApi {
  /// If [androidSdkInt] <= 33 (Android Version <= 12) it is auto-granted, so
  /// you won't see the request permissions prompt at all.
  void _requestNotificationPermissions() async {
    final l10n = AppLocalizations.of(context);
    final isDenied = await Permission.notification.isDenied;
    final logger = context.read<LoggerProvider>().logger;
    final userProvider = context.read<UserProvider>();

    if (isDenied) {
      await Permission.notification.request();
    }

    try {
      final connections = (await addUserNewConnections()).data.cast<String>();

      await userProvider.setConnections(connections, silent: false);
    } catch (error) {
      logger.e(error, time: DateTime.now());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n!.pgOnboardSplashCompleteEmptyErrorText),
        ),
      );
    }

    await userProvider.setOnboarded(true, localOnly: false);
    Navigator.of(context).pushReplacementNamed("/");
  }

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => _requestNotificationPermissions());
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
