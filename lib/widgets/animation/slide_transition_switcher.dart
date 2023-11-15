import 'package:animations/animations.dart';

class SlideTransitionSwitcher extends PageTransitionSwitcher {
  SlideTransitionSwitcher({
    super.key,
    super.child,
    super.reverse,
    super.duration,
  }) : super(
          transitionBuilder: (child, animation, secondaryAnimation) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
        );
}
