import 'package:flutter/material.dart';

/// An alternative of SlideTransitionSwitcher due to a visual twitch flaw
/// when the content height is different
class SlideAnimatedSwitcher extends AnimatedSwitcher {
  SlideAnimatedSwitcher({
    super.key,
    super.child,
    required super.duration,
    required this.reverse,
  }) : super(
          reverseDuration: const Duration(seconds: 0),
          transitionBuilder: (child, animation) {
            var tween = Tween(
                    begin: reverse
                        ? const Offset(-1.0, 0.0)
                        : const Offset(1.0, 0.0),
                    end: reverse
                        ? const Offset(0.0, 0.0)
                        : const Offset(0.0, 0.0))
                .chain(CurveTween(curve: Curves.easeInCubic));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );

  final bool reverse;
}
