import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/mixins/mixin_onboard_state.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/pages/onboard/page_onboard_home.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/animation/slide_transition_switcher.dart';
import 'package:red_flags/widgets/profile/profile_display_name.dart';
import 'package:red_flags/widgets/profile/profile_full_name.dart';
import 'package:red_flags/widgets/profile/profile_kyc.dart';
import 'package:red_flags/widgets/scaffold_page_onboard.dart';

/// Step 1 - First/Last name
/// Step 2 - Preferred (display) name
/// Step 3 - ID verification (KYC)
const maxSteps = 3;

/// Onboarding stage 1 Account verification Scaffold
class PageOnboardStage1 extends StatefulWidget {
  const PageOnboardStage1({super.key, required this.initStep});

  final int initStep;

  @override
  State<PageOnboardStage1> createState() => _PageOnboardStage1State();
}

class _PageOnboardStage1State extends State<PageOnboardStage1>
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
          builder: (context) => const PageOnboardHome(fromStage: 1),
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
    _userProvider = Provider.of<UserProvider>(context, listen: false);

    _firstNameCtrl.text = _userProvider.getFirstNameCache();
    _lastNameCtrl.text = _userProvider.getLastNameCache();
    _displayNameCtrl.text = _userProvider.getDisplayNameCache();

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScaffoldPageOnboard(
      step: step,
      maxSteps: maxSteps,
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
      onNextPressed: submitting
          ? null
          : () async {
              final verifySubmitted = _userProvider.getVerifySubmittedCache();

              if (!onboardForm.currentState!.validate() ||
                  (step == 2 && verifySubmitted != true)) {
                return;
              }

              setSubmitting(true);

              final firstName = _firstNameCtrl.text;
              final lastName = _lastNameCtrl.text;
              final displayName = _displayNameCtrl.text;

              if (step == 0 &&
                  (_userProvider.getFirstNameCache() != firstName ||
                      _userProvider.getLastNameCache() != lastName)) {
                // Update local cache only
                await _userProvider.setFirstName(firstName);
                await _userProvider.setLastName(lastName);

                // Aggregate Firebase update API calls into one
                await _userProvider.userDocRef?.update({
                  UserFields.firstName.name: firstName,
                  UserFields.lastName.name: lastName,
                });
              } else if (step == 1 &&
                  _userProvider.getDisplayNameCache() != displayName) {
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
        child: SlideTransitionSwitcher(
          reverse: slideTransitionReverse,
          child: step == 0
              ? ProfileFullName(
                  enabled: !submitting,
                  firstNameCtrl: _firstNameCtrl,
                  lastNameCtrl: _lastNameCtrl,
                )
              : step == 1
                  ? ProfileDisplayName(
                      enabled: !submitting,
                      controller: _displayNameCtrl,
                    )
                  : const ProfileKyc(onboarding: true),
        ),
      ),
    );
  }
}
