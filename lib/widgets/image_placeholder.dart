import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ImagePlaceholder extends StatefulWidget {
  const ImagePlaceholder({
    super.key,
    this.iconSize,
    this.error,
    this.loading,
    this.width,
    this.height,
  });

  final double? iconSize;
  final Object? error;
  final bool? loading;
  final double? width;
  final double? height;

  @override
  State<ImagePlaceholder> createState() => _ImagePlaceholderState();
}

class _ImagePlaceholderState extends State<ImagePlaceholder> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = widget.error;
    final hasError = error != null;

    return Tooltip(
      message: error?.toString() ?? '',
      triggerMode: TooltipTriggerMode.tap,
      child: Container(
        height: widget.height,
        width: widget.width,
        color: hasError
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.surfaceVariant.withOpacity(0.5),
        child: widget.loading == true
            ? LoadingAnimationWidget.fourRotatingDots(
                color: theme.colorScheme.surface,
                size: widget.iconSize ?? 60,
              )
            : Icon(
                hasError ? Icons.error_outline_outlined : Icons.photo_library,
                size: widget.iconSize ?? 60,
                shadows: [
                  BoxShadow(
                    offset: const Offset(-1, 1),
                    blurRadius: 2,
                    color: theme.colorScheme.outlineVariant,
                  )
                ],
                color: hasError
                    ? theme.colorScheme.error
                    : theme.colorScheme.surface,
              ),
      ),
    );
  }
}
