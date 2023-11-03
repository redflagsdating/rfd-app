import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/mixins/mixin_onboard_state.dart';
import 'package:red_flags/widgets/page_slide_transition_switcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

const maxSteps = 3;
const sharedPrefKey = "intro";

class PageSignInIntro extends StatefulWidget {
  const PageSignInIntro({super.key});

  @override
  State<PageSignInIntro> createState() => _PageSignInIntroState();
}

class _PageSignInIntroState extends State<PageSignInIntro>
    with MixinOnboardState {
  double _dragDx = 0.0;

  void _skip() {
    context.read<SharedPreferences>().setBool(sharedPrefKey, true);
    Navigator.of(context).pop();
  }

  void _navigate() {
    if (step < maxSteps - 1) {
      next();
    } else {
      _skip();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final headline = step == 1
        ? l10n!.pgIntroHeadline2(l10n.brandName)
        : step == 2
            ? l10n!.pgIntroHeadline3
            : l10n!.pgIntroHeadline1;
    final body = step == 1
        ? l10n.pgIntroBody2
        : step == 2
            ? l10n.pgIntroBody3
            : l10n.pgIntroBody1;

    return Scaffold(
      body: GestureDetector(
        onHorizontalDragStart: (details) {
          _dragDx = details.globalPosition.dx;
        },
        onHorizontalDragEnd: (details) {
          if (_dragDx >= MediaQuery.of(context).size.width / 2) {
            _navigate();
          } else {
            next(true);
          }

          _dragDx = 0;
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 36),
          child: Column(
            children: [
              const Spacer(),
              PageSlideTransitionSwitcher(
                reverse: slideTransitionReverse,
                duration: const Duration(milliseconds: 500),
                child: Column(
                  key: ValueKey(step),
                  children: [
                    // TODO: Placeholder, need to change to illustration
                    Container(
                      margin: const EdgeInsets.all(40),
                      height: 240,
                      decoration: const BoxDecoration(
                        color: Colors.black12,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      headline,
                      style: textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      body,
                      style: textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              DotsIndicator(
                dotsCount: maxSteps,
                position: step,
                decorator: DotsDecorator(
                  size: const Size.square(12.0),
                  activeSize: const Size.square(12.0),
                  color: colorScheme.primaryContainer,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: _skip,
                    child: Text(l10n.skip),
                  ),
                  const Spacer(),
                  FloatingActionButton(
                    shape: const CircleBorder(),
                    onPressed: _navigate,
                    child: const Icon(Icons.arrow_forward_ios_rounded),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
