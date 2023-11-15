import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardQuestion extends StatefulWidget {
  const CardQuestion({
    Key? key,
    this.question,
    this.answer,
    this.hintText,
    this.icon,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  final String? question;
  final String? answer;
  final String? hintText;
  final IconData? icon;
  final void Function()? onTap;
  final void Function()? onLongPress;

  @override
  State<CardQuestion> createState() => _CardQuestionState();
}

class _CardQuestionState extends State<CardQuestion> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeholderColor = theme.colorScheme.inversePrimary;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: () {
        final question = widget.question;
        final onLongPress = widget.onLongPress;

        if (question != null) {
          HapticFeedback.vibrate();

          if (onLongPress != null) {
            onLongPress();
          }
        }
      },
      child: Card(
        elevation: widget.question != null ? 2 : 0,
        child: widget.question != null
            ? Container(
                width: double.infinity,
                height: 120,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.question as String,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.answer ?? "...",
                      maxLines: 3,
                      overflow: TextOverflow.fade,
                      style: theme.textTheme.bodySmall,
                    )
                  ],
                ),
              )
            : DottedBorder(
                dashPattern: const [10, 5],
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                color: theme.colorScheme.inversePrimary,
                child: SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        size: 32,
                        widget.icon ?? Icons.question_answer_outlined,
                        color: placeholderColor,
                      ),
                      if (widget.hintText != null)
                        Text(
                          widget.hintText!,
                          style: theme.textTheme
                              .apply(bodyColor: placeholderColor)
                              .labelLarge,
                        )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
