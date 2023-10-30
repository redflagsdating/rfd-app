import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:red_flags/mixins/mixin_local_storage.dart';
import 'package:red_flags/pages/page_onboard_profile.dart';
import 'package:red_flags/pages/page_onboard_verification.dart';
import 'package:red_flags/widgets/onboarding/page_onboard_splash.dart';
import 'package:red_flags/widgets/page_fade_route_builder.dart';

enum OnboardingStage { verification, profile, redflags }

/// Entry page for onboarding to encapsulate business logic and better
/// transition UX.
class PageOnboardHome extends StatefulWidget {
  const PageOnboardHome({super.key, this.current});

  // Current stage
  final OnboardingStage? current;

  @override
  State<PageOnboardHome> createState() => _PageOnboardHomeState();
}

class _PageOnboardHomeState extends State<PageOnboardHome>
    with MixinLocalStorage {
  @override
  void initState() {
    super.initState();

    /// Better UX to show PageOnboardSplash animated spinning screen after sign
    /// in only
    Future.delayed(const Duration(milliseconds: 100), () {
      verification();
    });
  }

  void verification() {
    late String title;
    late String buttonLabel;
    late Builder builder;

    final l10n = AppLocalizations.of(context);
    final verifyStep1 = getFirstName() == "" || getLastName() == "";
    final verifyStep2 = getDisplayName() == "";
    final verifyStep3 = getVerifySubmitted() != true;

    final profileStep1 = getGender() == "";
    final profileStep2 = getGenderFor()?.isEmpty ?? true;
    final profileStep3 = getDob() == null;
    final profileStep4 = getReside() == "";

    ///** Onboarding stage 1 - Account verification
    if (widget.current == null && (verifyStep1 || verifyStep2 || verifyStep3)) {
      title = l10n!.pgOnboardSplash1Title;
      buttonLabel = l10n.pgOnboardSplash1Btn;
      builder = Builder(
        builder: (context) => PageOnboardVerification(
          initStep: verifyStep1
              ? 0
              : verifyStep2
                  ? 1
                  : verifyStep3
                      ? 2
                      : 0,
        ),
      );
    }

    ///** Onboarding stage 2 - Profile
    else if (widget.current == OnboardingStage.verification &&
        (profileStep1 || profileStep2 || profileStep3 || profileStep4)) {
      title = l10n!.pgOnboardSplash2Title;
      buttonLabel = l10n.pgOnboardSplash2Btn;
      builder = Builder(
        builder: (context) => PageOnboardProfile(
          initStep: profileStep1
              ? 0
              : profileStep2
                  ? 1
                  : 2,
        ),
      );
    }

    Navigator.of(context).pushReplacement(
      PageFadeRouteBuilder(
        transitionDuration: const Duration(seconds: 1),
        page: Builder(
          builder: (context) => PageOnboardSplash(
            title: title,
            buttonLabel: buttonLabel,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => builder,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const PageOnboardSplash(transition: true);
  }
}
