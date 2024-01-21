import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/pages/onboard/page_onboard_splash.dart';
import 'package:red_flags/pages/onboard/page_onboard_stage1.dart';
import 'package:red_flags/pages/onboard/page_onboard_stage2.dart';
import 'package:red_flags/pages/onboard/page_onboard_stage3.dart';
import 'package:red_flags/services/user_provider.dart';

/// Entry page for onboarding to encapsulate business logic and better
/// transition UX.
class PageOnboardHome extends StatefulWidget {
  const PageOnboardHome({super.key, this.fromStage});

  // Indicate navigation from. E.g. current == OnboardingStage.profile if
  // navigated from PageOnboardProfile
  final int? fromStage;

  @override
  State<PageOnboardHome> createState() => _PageOnboardHomeState();
}

class _PageOnboardHomeState extends State<PageOnboardHome> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 100), () async {
      late String title;
      late String buttonLabel;
      late Builder builder;

      final l10n = AppLocalizations.of(context);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Fetch user data from Firestore and update local cache at launch time
      if (widget.fromStage == null) {
        final userModel = await userProvider.getUserModel();

        if (userModel != null) {
          await userProvider.updateUserCache(userModel);
        }
      }

      final stage1Step1 = userProvider.getFirstNameCache().isEmpty ||
          userProvider.getLastNameCache().isEmpty;
      final stage1Step2 = userProvider.getDisplayNameCache().isEmpty;
      final stage1 = stage1Step1 || stage1Step2;
      // TODO: Temporary disable it
      // final stage1 = stage1Step1 ||
      //     stage1Step2 ||
      //     userProvider.getVerifySubmittedCache() != true;

      final stage2Step1 = userProvider.getGenderCache().isEmpty;
      final stage2Step2 = userProvider.getGenderForCache().isEmpty;
      final stage2Step3 = userProvider.getDobCache() == null;
      final stage2Step4 = userProvider.getLocalityCache().isEmpty;
      final stage2 = stage2Step1 ||
          stage2Step2 ||
          stage2Step3 ||
          stage2Step4 ||
          userProvider.getPhotoUrlCache().isEmpty;

      final stage3Step1 = userProvider.getRealTalkCache()?.isEmpty ?? true;
      final stage3Step2 = userProvider.getRedFlagsCache().isEmpty;
      final stage3 = stage3Step1 ||
          stage3Step2 ||
          userProvider.getGreenFlagsCache().isEmpty;

      ///** Onboarding stage 1 - Account verification
      if (stage1) {
        title = l10n!.pgOnboardSplash1Title;
        buttonLabel = l10n.pgOnboardSplash1Btn;
        builder = Builder(
          // Always starts from step 0 to force user clarify legal name
          builder: (context) => const PageOnboardStage1(initStep: 0),
        );
      }

      ///** Onboarding stage 2 - Profile
      else if (stage2) {
        title = l10n!.pgOnboardSplash2Title;
        buttonLabel = l10n.pgOnboardSplash2Btn;
        builder = Builder(
          builder: (context) => PageOnboardStage2(
            initStep: stage2Step1
                ? 0
                : stage2Step2
                    ? 1
                    : stage2Step3
                        ? 2
                        : stage2Step4
                            ? 3
                            : 4,
          ),
        );
      } else if (stage3) {
        title = l10n!.pgOnboardSplash3Title;
        buttonLabel = l10n.pgOnboardSplash3Btn;
        builder = Builder(
          builder: (context) => PageOnboardStage3(
            initStep: stage3Step1
                ? 0
                : stage3Step2
                    ? 1
                    : 2,
          ),
        );
      } else {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacementNamed("/");
        return;
      }

      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
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
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
