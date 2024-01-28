import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:red_flags/widgets/circle_avatar_user.dart';

class CardQodAnswer extends StatefulWidget {
  const CardQodAnswer({
    super.key,
    required this.answer,
    this.photoUrl,
    this.color,
    this.locked,
  });
  final String answer;
  final String? photoUrl;
  final Color? color;
  final bool? locked;

  @override
  State<CardQodAnswer> createState() => _CardQodAnswerState();
}

class _CardQodAnswerState extends State<CardQodAnswer> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Stack(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 80,
            minWidth: double.maxFinite,
          ),
          child: Card(
            elevation: 0,
            color: widget.color ?? theme.colorScheme.surfaceVariant,
            margin: const EdgeInsets.all(0),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 80,
                right: 20,
                top: 12,
                bottom: 12,
              ),
              child: Text(
                widget.answer,
                overflow: widget.locked == true ? TextOverflow.ellipsis : null,
                semanticsLabel: widget.answer,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 20,
          child: CircleAvatarUser(
            photoUrl: widget.photoUrl,
            size: 50,
          ),
        ),
        if (widget.locked == true)
          Positioned(
            right: 20,
            bottom: 10,
            child: Text.rich(
              TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Icon(
                        Icons.lock,
                        size: 14,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                  TextSpan(
                    text: l10n!.cardQodAnswerLockedLabel,
                    semanticsLabel: l10n.cardQodAnswerLockedLabel,
                    style: theme.textTheme
                        .apply(bodyColor: theme.colorScheme.outline)
                        .labelSmall,
                  ),
                ],
              ),
              maxLines: 1,
            ),
          ),
      ],
    );
  }
}
