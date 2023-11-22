import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';

class ScaffoldOnboard extends Scaffold {
  ScaffoldOnboard({
    super.key,
    required this.step,
    required this.maxSteps,
    required this.content,
    required this.stepIndicatorColor,
    this.appBarBackground,
    this.onBackPressed,
    this.onSkipPressed,
    this.onNextPressed,
  }) : super(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: appBarBackground,
            surfaceTintColor: appBarBackground,
            leading: IconButton(
                onPressed: onBackPressed,
                icon: const Icon(Icons.arrow_back_ios_new_rounded)),
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
          ),
          floatingActionButton: FloatingActionButton(
            enableFeedback: true,
            shape: const CircleBorder(),
            onPressed: onNextPressed,
            child: const Icon(Icons.arrow_forward_ios_rounded),
          ),
          body: Builder(
            builder: (context) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 36,
                ),
                child: content,
              );
            },
          ),
        );

  final int step;
  final int maxSteps;
  final Widget content;
  final Color stepIndicatorColor;
  final Color? appBarBackground;
  final void Function()? onBackPressed;
  final void Function()? onSkipPressed;
  final void Function()? onNextPressed;
}
