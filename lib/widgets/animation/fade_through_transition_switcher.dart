import 'package:animations/animations.dart';

class FadeThroughTransitionSwitcher extends PageTransitionSwitcher {
  FadeThroughTransitionSwitcher({
    super.key,
    super.child,
    super.duration,
  }) : super(
          transitionBuilder: (child, animation, secondaryAnimation) {
            return FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
        );
}
