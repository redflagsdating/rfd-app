import 'package:flutter/material.dart';
import 'package:red_flags/widgets/circle_avatar_user.dart';

class CardQodAnswer extends StatefulWidget {
  const CardQodAnswer({
    super.key,
    required this.answer,
    this.photoUrl,
    this.color,
  });
  final String answer;
  final String? photoUrl;
  final Color? color;

  @override
  State<CardQodAnswer> createState() => _CardQodAnswerState();
}

class _CardQodAnswerState extends State<CardQodAnswer> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Card(
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
              semanticsLabel: widget.answer,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
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
      ],
    );
  }
}
