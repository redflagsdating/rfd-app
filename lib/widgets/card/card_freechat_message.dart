import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/models/message.dart';
import 'package:red_flags/services/user_provider.dart';

class CardFreechatMessage extends StatefulWidget {
  const CardFreechatMessage({super.key, required this.message});

  final MessageModel message;

  @override
  State<CardFreechatMessage> createState() => _CardFreechatMessageState();
}

class _CardFreechatMessageState extends State<CardFreechatMessage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = widget.message.content;
    final createdAt = widget.message.createdAt;
    final userProvider = Provider.of<UserProvider>(context);
    final isMine = widget.message.uid == userProvider.getIdCache();

    // Do not show typing animation to self
    if (isMine && content == null) {
      return const SizedBox.shrink();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      textDirection: isMine ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isMine
                  ? theme.colorScheme.inversePrimary
                  : theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: Radius.circular(isMine ? 12 : 0),
                bottomRight: Radius.circular(isMine ? 0 : 12),
              ),
            ),
            child: content != null
                ? Text(
                    content,
                    style: const TextStyle(
                      fontSize: 14,
                      // Use default font family for the moment
                      fontFamily: '',
                    ),
                  )
                : LoadingAnimationWidget.prograssiveDots(
                    color: theme.colorScheme.outline,
                    size: 24,
                  ),
          ),
        ),
        const SizedBox(width: 4),
        if (content != null)
          Text(
            DateFormat.jm(Platform.localeName).format(createdAt),
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.outline),
          ),
      ],
    );
  }
}
