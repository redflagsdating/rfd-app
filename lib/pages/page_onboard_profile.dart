import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/mixins/mixin_onboard_state.dart';
import 'package:red_flags/pages/page_onboard_home.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/page_slide_transition_switcher.dart';
import 'package:red_flags/widgets/profile_birthday.dart';
import 'package:red_flags/widgets/profile_gender.dart';
import 'package:red_flags/widgets/profile_locality.dart';
import 'package:red_flags/widgets/profile_photos.dart';
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
    with MixinOnboardState {
  late UserProvider _userProvider;
  final _birthdayCtrl = TextEditingController();
  final _localityCtrl = TextEditingController();

  void _next() {
    if (step < maxSteps - 1) {
      next();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const PageOnboardHome(
            current: OnboardingStage.profile,
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

    final dob = _userProvider.getDobCache();
    if (dob != null) {
      _birthdayCtrl.text = DateFormat.yMd().format(dob);
    }

    _localityCtrl.text = _userProvider.getLocalityCache() ?? "";

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
              final gender = _userProvider.getGenderCache();
              final genderFor = _userProvider.getGenderForCache();
              final photoUrl = _userProvider.getPhotoUrlCache();

              if (!onboardForm.currentState!.validate() ||
                  (step == 0 && (gender == null || gender.isEmpty)) ||
                  (step == 1 && (genderFor == null || genderFor.isEmpty)) ||
                  (step == 4 && (photoUrl == null || photoUrl.isEmpty))) {
                return;
              }

              setSubmitting(true);

              final dob = DateFormat.yMd().parse(_birthdayCtrl.text);
              final locality = _localityCtrl.text;
              final dobCache = _userProvider.getDobCache();

              if (step == 0) {
                await _userProvider.setGender(gender as String);
              } else if (step == 1) {
                await _userProvider.setGenderFor(genderFor as List<String>);
              } else if (step == 2 &&
                  (dobCache == null || !dob.isAtSameMomentAs(dobCache))) {
                await _userProvider.setDob(dob, localOnly: false);
              } else if (step == 3) {
                await _userProvider.setLocality(locality, localOnly: false);
              }

              setSubmitting(false);
              _next();
            },
      content: Form(
        key: onboardForm,
        child: PageSlideTransitionSwitcher(
          reverse: slideTransitionReverse,
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
                          : ProfilePhotos(
                              enabled: !submitting,
                            ),
        ),
      ),
    );
  }
}
