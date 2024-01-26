import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/mixins/mixin_file.dart';
import 'package:red_flags/services/fire_storage_provider.dart';
import 'package:red_flags/services/logger_provider.dart';

class CircleAvatarUser extends StatefulWidget {
  const CircleAvatarUser({super.key, this.photoUrl, this.size});

  final String? photoUrl;
  final double? size;

  @override
  State<CircleAvatarUser> createState() => _CircleAvatarUserState();
}

class _CircleAvatarUserState extends State<CircleAvatarUser> with MixinFile {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logger = Provider.of<LoggerProvider>(context).logger;
    final storageProvider = context.read<FireStorageProvider>();
    final defaultSize = widget.size ?? 120;
    final radius = (defaultSize > 0 ? defaultSize : 120) / 2;

    return FutureBuilder(
      future: storageProvider.cacheImage(widget.photoUrl),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircleAvatar(
            maxRadius: radius,
            minRadius: radius,
            backgroundColor: theme.colorScheme.outlineVariant.withOpacity(0.2),
            child: LoadingAnimationWidget.fourRotatingDots(
              color: theme.colorScheme.outlineVariant.withOpacity(0.6),
              size: radius / 2,
            ),
          );
        }

        if (snapshot.hasData) {
          return CachedNetworkImage(
            width: defaultSize,
            height: defaultSize,
            imageUrl: snapshot.data!,
            useOldImageOnUrlChange: true,
            errorWidget: (context, url, error) {
              return Tooltip(
                triggerMode: TooltipTriggerMode.tap,
                message: error.toString(),
                child: CircleAvatar(
                  maxRadius: radius,
                  minRadius: radius,
                  backgroundColor: theme.colorScheme.errorContainer,
                  child: Icon(
                    Icons.person_off_outlined,
                    color: theme.colorScheme.error,
                    size: radius,
                  ),
                ),
              );
            },
            imageBuilder: (context, imageProvider) {
              return CircleAvatar(
                maxRadius: radius,
                minRadius: radius,
                backgroundImage: imageProvider,
                onBackgroundImageError: (exception, stackTrace) {
                  logger.e(exception, time: DateTime.now());
                },
              );
            },
          );
        }

        return CircleAvatar(
          maxRadius: radius,
          minRadius: radius,
          backgroundColor: theme.colorScheme.outlineVariant.withOpacity(0.2),
          child: Icon(
            Icons.person,
            color: theme.colorScheme.outlineVariant.withOpacity(0.6),
            size: radius,
          ),
        );
      },
    );
  }
}
