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
    final verifySubmitted = localStorage.getBool(
      UserFields.verifySubmitted.name,
    );

    final step1 = firstName == "" || lastName == "";
    final step2 = displayName == "";
    final step3 = verifySubmitted != true;

    ///** Onboarding stage 1 - Account verification
    /// Step 1 - First/Last name
    /// Step 2 - Preferred (display) name
    /// Step 3 - ID verification (KYC)
    if (step1 || step2 || step3) {
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
                      initStep: step1
                          ? 0
                          : step2
                              ? 1
                              : step3
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
