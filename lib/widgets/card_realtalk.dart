import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CardRealTalk extends StatefulWidget {
  const CardRealTalk({
    Key? key,
    this.question,
    this.answer,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  final String? question;
  final String? answer;
  final void Function()? onTap;
  final void Function()? onLongPress;

  @override
  State<CardRealTalk> createState() => _CardRealTalkState();
}

class _CardRealTalkState extends State<CardRealTalk> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
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
                        Icons.question_answer_outlined,
                        color: placeholderColor,
                      ),
                      Text(
                        l10n!.cardRealTalkText,
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
