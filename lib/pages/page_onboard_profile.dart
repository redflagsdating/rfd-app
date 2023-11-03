import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:red_flags/mixins/mixin_local_storage.dart';
import 'package:red_flags/mixins/mixin_onboard_state.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/pages/page_onboard_home.dart';
import 'package:red_flags/widgets/page_slide_transition_switcher.dart';
import 'package:red_flags/widgets/profile_birthday.dart';
import 'package:red_flags/widgets/profile_gender.dart';
import 'package:red_flags/widgets/profile_locality.dart';
import 'package:red_flags/widgets/scaffold_onboard.dart';

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
  final _birthdayCtrl = TextEditingController();
  final _localityCtrl = TextEditingController();

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

    final dob = getDob();
    _localityCtrl.text = getLocality() ?? "";

    if (dob != null) {
      _birthdayCtrl.text = DateFormat.yMd().format(dob);
    }

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
              final dob = DateFormat.yMd().parse(_birthdayCtrl.text);
              final locality = _localityCtrl.text;

              if (step == 0) {
                await usersRef
                    .doc(uid)
                    .update({UserFields.gender.name: gender});
              } else if (step == 1) {
                await usersRef
                    .doc(uid)
                    .update({UserFields.genderFor.name: genderFor});
              } else if (step == 2 && !dob.isAtSameMomentAs(getDob()!)) {
                await setDob(dob);
                await usersRef.doc(uid).update({UserFields.dob.name: dob});
              } else if (step == 3) {
                await setLocality(locality);
                await usersRef
                    .doc(uid)
                    .update({UserFields.locality.name: locality});
              }

              setSubmitting(false);
              _next();
            },
      content: Form(
        key: onboardForm,
        child: PageSlideTransitionSwitcher(
          reverse: slideTransitionReverse,
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
                  : step == 2
                      ? ProfileBirthday(
                          enabled: !submitting,
                          controller: _birthdayCtrl,
                        )
                      : step == 3
                          ? ProfileLocality(
                              enabled: !submitting,
                              controller: _localityCtrl,
                            )
                          : const Text("TODO"),
        ),
      ),
    );
  }
}
