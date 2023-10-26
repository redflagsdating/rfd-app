import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class PageFadeRouteBuilder extends PageRouteBuilder {
  final Builder page;

  PageFadeRouteBuilder({
    required this.page,
    super.transitionDuration,
    super.reverseTransitionDuration,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) {
            return page.build(context);
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
        );
}
