import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/mixins/mixin_file.dart';
import 'package:red_flags/services/fire_storage_provider.dart';
import 'package:red_flags/services/logger_provider.dart';
import 'package:red_flags/widgets/badge_kyc_status.dart';

class CircleAvatarUser extends StatefulWidget {
  const CircleAvatarUser({super.key, this.photoUrl});

  final String? photoUrl;

  @override
  State<CircleAvatarUser> createState() => _CircleAvatarUserState();
}

class _CircleAvatarUserState extends State<CircleAvatarUser> with MixinFile {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logger = Provider.of<LoggerProvider>(context).logger;
    final storageProvider = context.read<FireStorageProvider>();

    return BadgeKycStatus(
      alignment: Alignment.bottomRight,
      backgroundColor: theme.colorScheme.onSecondary.withOpacity(0.8),
      child: FutureBuilder(
        future: storageProvider.cacheImage(widget.photoUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircleAvatar(
              maxRadius: 60,
              minRadius: 60,
              backgroundColor:
                  theme.colorScheme.outlineVariant.withOpacity(0.2),
              child: LoadingAnimationWidget.fourRotatingDots(
                color: theme.colorScheme.outlineVariant.withOpacity(0.6),
                size: 36,
              ),
            );
          }

          if (snapshot.hasData) {
            return CachedNetworkImage(
              width: 120,
              height: 120,
              imageUrl: snapshot.data!,
              useOldImageOnUrlChange: true,
              errorWidget: (context, url, error) {
                return Tooltip(
                  triggerMode: TooltipTriggerMode.tap,
                  message: error.toString(),
                  child: CircleAvatar(
                    maxRadius: 60,
                    minRadius: 60,
                    backgroundColor: theme.colorScheme.errorContainer,
                    child: Icon(
                      Icons.person_off_outlined,
                      color: theme.colorScheme.error,
                      size: 60,
                    ),
                  ),
                );
              },
              imageBuilder: (context, imageProvider) {
                return CircleAvatar(
                  maxRadius: 60,
                  minRadius: 60,
                  backgroundImage: imageProvider,
                  onBackgroundImageError: (exception, stackTrace) {
                    logger.e(exception, time: DateTime.now());
                  },
                );
              },
            );
          }

          return CircleAvatar(
            maxRadius: 60,
            minRadius: 60,
            backgroundColor: theme.colorScheme.outlineVariant.withOpacity(0.2),
            child: Icon(
              Icons.person,
              color: theme.colorScheme.outlineVariant.withOpacity(0.6),
              size: 60,
            ),
          );
        },
      ),
    );
  }
}
