import 'package:flutter/material.dart';
import 'package:red_flags/mixins/mixin_local_storage.dart';
import 'package:red_flags/mixins/mixin_onboard_state.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/pages/page_onboard_home.dart';
import 'package:red_flags/widgets/page_slide_transition_switcher.dart';
import 'package:red_flags/widgets/scaffold_onboard.dart';
import 'package:red_flags/widgets/verification_display_name.dart';
import 'package:red_flags/widgets/verification_full_name.dart';

/// Step 1 - First/Last name
/// Step 2 - Preferred (display) name
/// Step 3 - ID verification (KYC)
const maxSteps = 3;

/// Onboarding stage 1 Account verification Scaffold
class PageOnboardVerification extends StatefulWidget {
  const PageOnboardVerification({
    Key? key,
    required this.initStep,
  }) : super(key: key);

  final int initStep;

  @override
  State<PageOnboardVerification> createState() =>
      _PageOnboardVerificationState();
}

class _PageOnboardVerificationState extends State<PageOnboardVerification>
    with MixinOnboardState, MixinLocalStorage {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _displayNameCtrl = TextEditingController();

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

    _firstNameCtrl.text = getFirstName() ?? "";
    _lastNameCtrl.text = getLastName() ?? "";
    _displayNameCtrl.text = getDisplayName() ?? "";

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
        _next();
      },
      onNextPressed: submitting
          ? null
          : () async {
              if (!onboardForm.currentState!.validate()) {
                return;
              }

              setSubmitting(true);

              final uid = getUserId();
              final firstName = _firstNameCtrl.text;
              final lastName = _lastNameCtrl.text;
              final displayName = _displayNameCtrl.text;

              if (step == 0 &&
                  (getFirstName() != firstName || getLastName() != lastName)) {
                setFirstName(firstName);
                setLastName(lastName);

                await usersRef.doc(uid).update({
                  UserFields.firstName.name: firstName,
                  UserFields.lastName.name: lastName,
                });
              } else if (step == 1 && getDisplayName() != displayName) {
                setDisplayName(displayName);

                await usersRef
                    .doc(uid)
                    .update({UserFields.displayName.name: displayName});
              } else {
                /// The delay prevents immediate state change from true to
                /// false by _setLoading when no data changes are needed to
                /// save to Firestore. This ensure "autofocus" of TextFormField
                /// works as expected as the delay allows loading state change
                /// reflects to the "enabled" state of TextFormField which
                /// triggers unfocus automatically.
                await Future.delayed(const Duration(milliseconds: 100));
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
              ? VerificationFullName(
                  enabled: !submitting,
                  firstNameCtrl: _firstNameCtrl,
                  lastNameCtrl: _lastNameCtrl,
                )
              : step == 1
                  ? VerificationDisplayName(
                      enabled: !submitting,
                      controller: _displayNameCtrl,
                    )
                  // TODO
                  : step == 2
                      ? const Text("KYC")
                      : const Text("Unknown"),
        ),
      ),
    );
  }
}
