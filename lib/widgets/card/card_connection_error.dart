import 'package:flutter/material.dart';

class CardConnectionError extends StatelessWidget {
  const CardConnectionError({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 440,
      width: 310,
      child: Card(
        color: theme.colorScheme.errorContainer,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.onErrorContainer,
            ),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme
                  .apply(
                    bodyColor: theme.colorScheme.onErrorContainer,
                  )
                  .labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}
