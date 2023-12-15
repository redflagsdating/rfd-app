import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/services/fire_storage_provider.dart';
import 'package:red_flags/widgets/card_question.dart';
import 'package:red_flags/widgets/image_placeholder.dart';
import 'package:red_flags/widgets/user_profile_banner.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key, required this.userModel});
  final UserModel userModel;

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  bool _loading = true;
  final List<String?> _photoUrls = [];

  @override
  void initState() {
    final storageProvider = context.read<FireStorageProvider>();
    final userImgRef = storageProvider.imgStorageForRef(widget.userModel.uid);

    userImgRef.listAll().then((images) {
      images.items.where((element) {
        return element.fullPath != widget.userModel.photoUrl;
      }).forEach((element) {
        storageProvider.cacheImage(element.fullPath).then((value) {
          setState(() {
            _photoUrls.add(value);

            if (_loading) {
              _loading = false;
            }
          });
        });
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final redFlags = widget.userModel.redFlags;
    final greenFlags = widget.userModel.greenFlags;
    final realtalk = widget.userModel.realTalk;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserProfileBanner(userModel: widget.userModel),
          const SizedBox(height: 40),
          Text.rich(
            TextSpan(
              children: [
                WidgetSpan(
                  child: Icon(
                    Icons.flag_circle_sharp,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const WidgetSpan(child: SizedBox(width: 4)),
                TextSpan(
                  text: l10n!.brandName,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            children: List.generate(
              redFlags!.length,
              (index) {
                return Chip(
                  label: Text(redFlags[index]),
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Text.rich(
            TextSpan(
              children: [
                const WidgetSpan(
                  child: Icon(
                    Icons.flag_circle_sharp,
                    color: Colors.green,
                  ),
                ),
                const WidgetSpan(child: SizedBox(width: 4)),
                TextSpan(
                  text: l10n.greenFlags,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            children: List.generate(
              greenFlags!.length,
              (index) {
                return Chip(
                  label: Text(greenFlags[index]),
                  visualDensity: VisualDensity.compact,
                  surfaceTintColor: theme.colorScheme.primaryContainer,
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: List.generate(
              3,
              (index) {
                final prompt = realtalk?.entries.elementAtOrNull(index);
                final imageUrl = _photoUrls.elementAtOrNull(index);

                return Column(
                  children: [
                    imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: double.infinity,
                            height: 300,
                            useOldImageOnUrlChange: true,
                            errorWidget: (context, url, error) {
                              return ImagePlaceholder(error: error);
                            },
                            imageBuilder: (context, imageProvider) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: ImagePlaceholder(
                              height: 300,
                              loading: _loading,
                              width: double.infinity,
                            ),
                          ),
                    const SizedBox(height: 12),
                    prompt != null
                        ? Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.inversePrimary
                                  .withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset.zero,
                                  blurRadius: 4,
                                  color: theme.colorScheme.surfaceVariant,
                                )
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prompt.key,
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  prompt.value,
                                  style: theme.textTheme.bodySmall,
                                )
                              ],
                            ),
                          )
                        : CardQuestion(
                            listQuestions: const [],
                            hintText: l10n.brandTagLine,
                          ),
                    const SizedBox(height: 32),
                  ],
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              2,
              (index) {
                final imageUrl = _photoUrls.elementAtOrNull(index + 3);

                return imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 160,
                        height: 160,
                        useOldImageOnUrlChange: true,
                        errorWidget: (context, url, error) {
                          return ImagePlaceholder(error: error);
                        },
                        imageBuilder: (context, imageProvider) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ImagePlaceholder(
                          height: 160,
                          width: 160,
                          iconSize: 32,
                          loading: _loading,
                        ),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
