import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/mixins/mixin_onboard_state.dart';
import 'package:red_flags/pages/onboard/page_onboard_home.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/animation/slide_transition_switcher.dart';
import 'package:red_flags/widgets/profile/profile_birthday.dart';
import 'package:red_flags/widgets/profile/profile_gender.dart';
import 'package:red_flags/widgets/profile/profile_locality.dart';
import 'package:red_flags/widgets/profile/profile_photos.dart';
import 'package:red_flags/widgets/scaffold_page_onboard.dart';

/// Step 1 - Gender
/// Step 2 - Gender to meet
/// Step 3 - Birthday
/// Step 4 - Where do you live
/// Step 5 - Photos
const maxSteps = 5;

class PageOnboardStage2 extends StatefulWidget {
  const PageOnboardStage2({
    Key? key,
    required this.initStep,
  }) : super(key: key);

  final int initStep;

  @override
  State<PageOnboardStage2> createState() => _PageOnboardStage2State();
}

class _PageOnboardStage2State extends State<PageOnboardStage2>
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
          builder: (context) => const PageOnboardHome(fromStage: 2),
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

    final dob = _userProvider.getDobCache();
    if (dob != null) {
      _birthdayCtrl.text = DateFormat.yMd().format(dob);
    }

    _localityCtrl.text = _userProvider.getLocalityCache();

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
              final gender = _userProvider.getGenderCache();
              final genderFor = _userProvider.getGenderForCache();
              final photoUrl = _userProvider.getPhotoUrlCache();

              if (!onboardForm.currentState!.validate() ||
                  (step == 0 && gender.isEmpty) ||
                  (step == 1 && genderFor.isEmpty) ||
                  (step == 4 && photoUrl.isEmpty)) {
                return;
              }

              setSubmitting(true);

              final locality = _localityCtrl.text;
              final dobCache = _userProvider.getDobCache();

              if (step == 0) {
                await _userProvider.setGender(gender, localOnly: false);
              } else if (step == 1) {
                await _userProvider.setGenderFor(genderFor, localOnly: false);
              } else if (step == 2) {
                final dob = DateFormat.yMd().parse(_birthdayCtrl.text);
                if (dobCache == null || !dob.isAtSameMomentAs(dobCache)) {
                  await _userProvider.setDob(dob, localOnly: false);
                }
              } else if (step == 3) {
                await _userProvider.setLocality(locality, localOnly: false);
              }

              setSubmitting(false);
              _next();
            },
      content: Form(
        key: onboardForm,
        child: SlideTransitionSwitcher(
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
