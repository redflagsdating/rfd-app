import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/pages/page_onboard_verification.dart';
import 'package:red_flags/widgets/onboarding/page_onboard_splash.dart';
import 'package:red_flags/widgets/page_fade_route_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Entry page for onboarding to encapsulate business logic and better
/// transition UX.
class PageOnboardHome extends StatefulWidget {
  const PageOnboardHome({super.key});

  @override
  State<PageOnboardHome> createState() => _PageOnboardHomeState();
}

class _PageOnboardHomeState extends State<PageOnboardHome> {
  @override
  void initState() {
    super.initState();

    // Better UX with delay to show PageOnboardSplash animated splash screen
    Future.delayed(const Duration(milliseconds: 300), () {
      verification();
    });
  }

  void verification() {
    final l10n = AppLocalizations.of(context);
    final localStorage = context.read<SharedPreferences>();

    final firstName = localStorage.getString(UserFields.firstName.name);
    final lastName = localStorage.getString(UserFields.lastName.name);
    final displayName = localStorage.getString(UserFields.displayName.name);
    final verifySubmitted =
        localStorage.getBool(UserFields.verifySubmitted.name);

    final verifyStep1 = firstName == "" || lastName == "";
    final verifyStep2 = displayName == "";
    final verifyStep3 = verifySubmitted != true;

    ///** Onboarding stage 1 - Account verification
    /// - First/Last name
    /// - Preferred (display) name
    /// - ID verification (KYC)
    if (verifyStep1 || verifyStep2 || verifyStep3) {
      Navigator.of(context).pushReplacement(
        PageFadeRouteBuilder(
          transitionDuration: const Duration(seconds: 1),
          page: Builder(
            builder: (context) => PageOnboardSplash(
              title: l10n!.pgOnboardSplash1Title,
              buttonLabel: l10n.pgOnboardSplash1Btn,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PageOnboardVerification(
                      initFirstName: firstName,
                      initLastName: lastName,
                      initDisplayName: displayName,
                      initStep: verifyStep1
                          ? 0
                          : verifyStep2
                              ? 1
                              : verifyStep3
                                  ? 2
                                  : maxSteps,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const PageOnboardSplash(transition: true);
  }
}
