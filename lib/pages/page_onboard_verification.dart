import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/mixins/mixin_onboard_state.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/pages/page_onboard_home.dart';
import 'package:red_flags/services/user_provider.dart';
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
    with MixinOnboardState {
  late UserProvider _userProvider;
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
  void initState() {
    step = widget.initStep;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _userProvider = Provider.of<UserProvider>(context);

    _firstNameCtrl.text = _userProvider.getFirstNameCache() ?? "";
    _lastNameCtrl.text = _userProvider.getLastNameCache() ?? "";
    _displayNameCtrl.text = _userProvider.getDisplayNameCache() ?? "";

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
      //TODO: Skip prompt
      // onSkipPressed: () {
      //   _next();
      // },
      onNextPressed: submitting
          ? null
          : () async {
              if (!onboardForm.currentState!.validate()) {
                return;
              }

              setSubmitting(true);

              final firstName = _firstNameCtrl.text;
              final lastName = _lastNameCtrl.text;
              final displayName = _displayNameCtrl.text;

              if (step == 0 &&
                  (await _userProvider.getFirstName() != firstName ||
                      await _userProvider.getLastName() != lastName)) {
                await _userProvider.setFirstName(firstName);
                await _userProvider.setLastName(lastName);
                await _userProvider.userDocRef?.update({
                  UserFields.firstName.name: firstName,
                  UserFields.lastName.name: lastName,
                });
              } else if (step == 1 &&
                  await _userProvider.getDisplayName() != displayName) {
                await _userProvider.setDisplayName(displayName,
                    localOnly: false);
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
                  : const Text("KYC"),
        ),
      ),
    );
  }
}
