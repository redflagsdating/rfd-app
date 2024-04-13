import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CardConnectionPlaceholder extends StatelessWidget {
  const CardConnectionPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 440,
      width: 310,
      child: Card(
        child: LoadingAnimationWidget.beat(
          color: theme.colorScheme.primaryContainer,
          size: 48,
        ),
      ),
    );
  }
}
