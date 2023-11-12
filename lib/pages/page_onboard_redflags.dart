import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/mixins/mixin_onboard_state.dart';
import 'package:red_flags/pages/page_home.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/page_slide_transition_switcher.dart';
import 'package:red_flags/widgets/profile_greenflags.dart';
import 'package:red_flags/widgets/profile_realtalk.dart';
import 'package:red_flags/widgets/profile_redflags.dart';
import 'package:red_flags/widgets/scaffold_onboard.dart';

/// Step 1 - Real talk
/// Step 2 - Redflags
/// Step 3 - Green flags
const maxSteps = 3;

class PageOnboardRedflags extends StatefulWidget {
  const PageOnboardRedflags({
    Key? key,
    required this.initStep,
  }) : super(key: key);

  final int initStep;

  @override
  State<PageOnboardRedflags> createState() => _PageOnboardRedflagsState();
}

class _PageOnboardRedflagsState extends State<PageOnboardRedflags>
    with MixinOnboardState {
  late UserProvider _userProvider;
  void _next() {
    if (step < maxSteps - 1) {
      next();
    } else {
      // TODO: Splash then root
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const PageHome()),
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
              final realTalk = _userProvider.getRealTalkCache();

              if (step == 0 && realTalk != null) {
                _userProvider.setRealTalk(realTalk);
              }

              _next();
            },
      content: Form(
        key: onboardForm,
        child: PageSlideTransitionSwitcher(
          reverse: slideTransitionReverse,
          child: step == 0
              ? const ProfileRealTalk()
              : step == 1
                  ? const ProfileRedFlags()
                  : const ProfileGreenFlags(),
        ),
      ),
    );
  }
}
