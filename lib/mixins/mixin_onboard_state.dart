import 'package:flutter/material.dart';

mixin MixinOnboardState<T extends StatefulWidget> on State<T> {
  // Key for Form widget when onboarding page contain form fields
  final onboardForm = GlobalKey<FormState>();

  // Current step of the onboarding stage (OnboardingStage)
  int step = 0;
  bool submitting = false;
  bool slideReverse = false;

  void setSubmitting(bool loading) {
    setState(() {
      submitting = loading;
    });
  }

  void next([bool? backward]) {
    setState(() {
      if (backward == true) {
        if (step > 0) {
          slideReverse = true;
          step--;
        }
      } else {
        slideReverse = false;
        step++;
      }
    });
  }
}
