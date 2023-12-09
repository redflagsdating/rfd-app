import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:red_flags/widgets/scaffold_page_basic.dart';

class ScaffoldPageOnboard extends ScaffoldPageBasic {
  ScaffoldPageOnboard({
    super.key,
    required super.content,
    super.actions,
    super.onBackPressed,
    required this.step,
    required this.maxSteps,
    required this.stepIndicatorColor,
    this.onSkipPressed,
    this.onNextPressed,
  }) : super(
          title: DotsIndicator(
            position: step,
            dotsCount: maxSteps,
            decorator: DotsDecorator(
              size: const Size.square(10),
              activeSize: const Size(30, 10),
              spacing: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              color: stepIndicatorColor,
            ),
          ),
          floatingActionButton: FloatingActionButton(
            enableFeedback: true,
            shape: const CircleBorder(),
            onPressed: onNextPressed,
            child: const Icon(Icons.arrow_forward_ios_rounded),
          ),
        );

  final int step;
  final int maxSteps;
  final Color stepIndicatorColor;
  final void Function()? onSkipPressed;
  final void Function()? onNextPressed;
}
