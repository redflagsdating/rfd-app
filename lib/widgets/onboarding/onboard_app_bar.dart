import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

class OnboardAppBar extends AppBar {
  final int step;
  final int maxSteps;
  final ThemeData theme;
  final void Function()? onBack;

  OnboardAppBar({
    super.key,
    required this.step,
    required this.theme,
    required this.maxSteps,
    this.onBack,
  }) : super(
          centerTitle: true,
          leading: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded)),
          title: DotsIndicator(
            dotsCount: maxSteps,
            position: step,
            decorator: DotsDecorator(
              size: const Size.square(10),
              activeSize: const Size(30, 10),
              spacing: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
              activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              color: theme.colorScheme.primaryContainer,
            ),
          ),
        );
}
