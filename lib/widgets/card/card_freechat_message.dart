import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/models/message.dart';
import 'package:red_flags/services/fire_storage_provider.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/cached_image.dart';

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
    final isImage = widget.message.type == MessageType.image;
    final isText = widget.message.type == MessageType.text;
    final hasContent = content != null;

    // Do not show typing animation to self
    if (isMine && !hasContent && isText) {
      return const SizedBox.shrink();
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      textDirection: isMine ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Flexible(
          child: Container(
            clipBehavior: Clip.hardEdge,
            padding: !isImage || !hasContent
                ? const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  )
                : null,
            decoration: BoxDecoration(
              color: isMine
                  ? theme.colorScheme.inversePrimary
                  : theme.colorScheme.onInverseSurface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: Radius.circular(isMine ? 12 : 0),
                bottomRight: Radius.circular(isMine ? 0 : 12),
              ),
            ),
            child: hasContent
                ? isImage
                    ? GestureDetector(
                        onTap: () async {
                          final imageUrl = await context
                              .read<FireStorageProvider>()
                              .cacheImage(content);

                          if (imageUrl != null) {
                            showGeneralDialog(
                              // ignore: use_build_context_synchronously
                              context: context,
                              pageBuilder:
                                  (context, animation, secondaryAnimation) {
                                return Scaffold(
                                  appBar: AppBar(
                                    leading: CloseButton(
                                      color: theme.colorScheme.onInverseSurface,
                                    ),
                                    backgroundColor:
                                        theme.colorScheme.inverseSurface,
                                  ),
                                  body: PhotoView(
                                    backgroundDecoration: BoxDecoration(
                                      color: theme.colorScheme.inverseSurface,
                                    ),
                                    initialScale:
                                        PhotoViewComputedScale.contained * 0.9,
                                    imageProvider:
                                        CachedNetworkImageProvider(imageUrl),
                                  ),
                                );
                              },
                            );
                          }
                        },
                        child: CachedImage(
                          photoUrl: content,
                          height: 260,
                          width: 260,
                        ),
                      )
                    : Text(
                        content,
                        style: const TextStyle(
                          fontSize: 14,
                          // Use default font family for the moment
                          fontFamily: '',
                        ),
                      )
                : isImage
                    ? LoadingAnimationWidget.fourRotatingDots(
                        color: theme.colorScheme.outline,
                        size: 24,
                      )
                    : LoadingAnimationWidget.prograssiveDots(
                        color: theme.colorScheme.outline,
                        size: 24,
                      ),
          ),
        ),
        const SizedBox(width: 4),
        if (hasContent)
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
