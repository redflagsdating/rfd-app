import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/pages/page_onboard_splash.dart';
import 'package:red_flags/services/fire_storage_provider.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/card_image_picker.dart';

class ProfilePhotos extends StatefulWidget {
  const ProfilePhotos({
    Key? key,
    required this.enabled,
  }) : super(key: key);

  final bool enabled;

  @override
  State<ProfilePhotos> createState() => _ProfilePhotosState();
}

class _ProfilePhotosState extends State<ProfilePhotos> {
  Future<ListResult>? _photosRefList;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final userProvider = context.read<UserProvider>();
    // final tipTextColor = theme.textTheme.apply(
    //   bodyColor: theme.colorScheme.secondaryContainer,
    //   displayColor: theme.colorScheme.secondaryContainer,
    // );
    _photosRefList ??=
        Provider.of<FireStorageProvider>(context).imgStorageRef.listAll();

    return FutureBuilder(
      future: _photosRefList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final listRef = snapshot.data!.items;
          final count = snapshot.data!.items.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n!.pgPhotoHeadline(userProvider.getDisplayNameCache()),
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(l10n.pgPhotoBody),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CardImagePicker(
                    size: 100,
                    enabled: widget.enabled,
                    imageRef: count > 0 ? listRef.first : null,
                  ),
                  CardImagePicker(
                    size: 100,
                    enabled: widget.enabled,
                    imageRef: count > 1 ? listRef[1] : null,
                  ),
                  CardImagePicker(
                    size: 100,
                    enabled: widget.enabled,
                    imageRef: count > 2 ? listRef[2] : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CardImagePicker(
                    size: 100,
                    enabled: widget.enabled,
                    imageRef: count > 3 ? listRef[3] : null,
                  ),
                  CardImagePicker(
                    size: 100,
                    enabled: widget.enabled,
                    imageRef: count > 4 ? listRef[4] : null,
                  ),
                  CardImagePicker(
                    size: 100,
                    enabled: widget.enabled,
                    imageRef: count > 5 ? listRef[5] : null,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                l10n.pgPhotoHelperText,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              // Card(
              //   color: theme.colorScheme.onSecondaryContainer,
              //   surfaceTintColor: theme.colorScheme.onSecondaryContainer,
              //   child: Container(
              //     width: double.infinity,
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 20,
              //       vertical: 14,
              //     ),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text.rich(
              //           TextSpan(
              //             style: tipTextColor.titleSmall,
              //             children: [
              //               WidgetSpan(
              //                 child: Icon(
              //                   Icons.lightbulb_rounded,
              //                   color: theme.colorScheme.secondaryContainer,
              //                 ),
              //               ),
              //               const WidgetSpan(
              //                 child: SizedBox(width: 4),
              //               ),
              //               TextSpan(text: l10n.pgPhotoTipTitle)
              //             ],
              //           ),
              //         ),
              //         const SizedBox(height: 8),
              //         Text(
              //           l10n.pgPhotoTipBody,
              //           style: tipTextColor.bodySmall,
              //         )
              //       ],
              //     ),
              //   ),
              // )
            ],
          );
        }

        return const PageOnboardSplash(transition: true);
      },
    );
  }
}
