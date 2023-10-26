import 'package:flutter/material.dart';

/// Splash page for onboarding milestones
class PageOnboardSplash extends StatefulWidget {
  final String? title;
  final String? buttonLabel;
  final VoidCallback? onPressed;
  final bool? transition;

  const PageOnboardSplash({
    super.key,
    this.title,
    this.buttonLabel,
    this.onPressed,
    this.transition,
  });

  @override
  State<PageOnboardSplash> createState() => _PageOnboardSplashState();
}

class _PageOnboardSplashState extends State<PageOnboardSplash> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 24, top: 200, right: 24, bottom: 80),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/onboard-splash-bg.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: widget.transition == true
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: widget.transition == true
            ? [
                CircularProgressIndicator(
                  strokeCap: StrokeCap.round,
                  color: theme.colorScheme.primary,
                )
              ]
            : [
                Image.asset(
                  "assets/rf-logo-red.png",
                  width: 120,
                ),
                const SizedBox(height: 24),
                Text(
                  widget.title ?? "",
                  style: theme.textTheme.titleLarge,
                ),
                const Spacer(),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(40),
                  ),
                  onPressed: () {
                    widget.onPressed!();
                  },
                  child: Text(widget.buttonLabel ?? ""),
                ),
              ],
      ),
    );
  }
}
