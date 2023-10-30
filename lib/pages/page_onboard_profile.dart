import 'package:flutter/material.dart';
import 'package:red_flags/mixins/mixin_local_storage.dart';
import 'package:red_flags/mixins/mixin_onboard_state.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/pages/page_onboard_home.dart';
import 'package:red_flags/widgets/onboarding/profile_gender.dart';
import 'package:red_flags/widgets/onboarding/scaffold_onboard.dart';
import 'package:red_flags/widgets/page_slide_transition_switcher.dart';

/// Step 1 - Gender
/// Step 2 - Gender to meet
/// Step 3 - Birthday
/// Step 4 - Where do you live
/// Step 5 - Photos
const maxSteps = 5;

class PageOnboardProfile extends StatefulWidget {
  const PageOnboardProfile({
    Key? key,
    required this.initStep,
  }) : super(key: key);

  final int initStep;

  @override
  State<PageOnboardProfile> createState() => _PageOnboardProfileState();
}

class _PageOnboardProfileState extends State<PageOnboardProfile>
    with MixinOnboardState, MixinLocalStorage {
  void _next() {
    if (step < maxSteps - 1) {
      next();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const PageOnboardHome(
            current: OnboardingStage.verification,
          ),
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    step = widget.initStep;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScaffoldOnboard(
      step: step,
      maxSteps: maxSteps,
      appBarBackground: theme.colorScheme.background,
      stepIndicatorColor: theme.colorScheme.primaryContainer,
      onBackPressed: submitting
          ? null
          : () {
              if (step == 0) {
                Navigator.of(context).pop();
              } else {
                next(true);
              }
            },
      onSkipPressed: () {
        //TODO: Skip prompt
        next();
      },
      onNextPressed: submitting
          ? null
          : () async {
              final gender = getGender();
              final genderFor = getGenderFor();

              if (!onboardForm.currentState!.validate() ||
                  (step == 0 && gender!.isEmpty) ||
                  (step == 1 && (genderFor == null || genderFor.isEmpty))) {
                return;
              }

              setSubmitting(true);

              final uid = getUserId();

              if (step == 0) {
                await usersRef
                    .doc(uid)
                    .update({UserFields.gender.name: gender});
              } else if (step == 1) {
                await usersRef
                    .doc(uid)
                    .update({UserFields.genderFor.name: genderFor});
              }

              setSubmitting(false);
              _next();
            },
      content: Form(
        key: onboardForm,
        child: PageSlideTransitionSwitcher(
          reverse: slideReverse,
          duration: const Duration(milliseconds: 500),
          child: step == 0
              ? ProfileGender(
                  enabled: !submitting,
                )
              : step == 1
                  ? ProfileGender(
                      enabled: !submitting,
                      genderFor: true,
                    )
                  : const Text("TODO"),
        ),
      ),
    );
  }
}
