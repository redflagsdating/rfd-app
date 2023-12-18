import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:red_flags/mixins/mixin_file.dart';
import 'package:red_flags/mixins/mixin_permissions.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/widgets/image_placeholder.dart';
import 'package:red_flags/widgets/user_profile.dart';

class PageProfileView extends StatefulWidget {
  const PageProfileView({
    super.key,
    required this.userModel,
    this.photoUrl,
    this.userImgStorageRef,
  });

  final UserModel userModel;
  final Reference? userImgStorageRef;

  /// Even though photoUrl can be retrieved from userModel, by passing photoUrl
  /// externally allows fetching image from cache first to improve UX
  final String? photoUrl;

  @override
  State<PageProfileView> createState() => _PageProfileViewState();
}

class _PageProfileViewState extends State<PageProfileView>
    with MixinFile, MixinPermissions {
  @override
  Widget build(BuildContext context) {
    final photoUrl = widget.photoUrl;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                photoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: photoUrl,
                        width: double.infinity,
                        height: 360,
                        useOldImageOnUrlChange: true,
                        errorWidget: (context, url, error) {
                          return ImagePlaceholder(error: error);
                        },
                        imageBuilder: (context, imageProvider) {
                          return Image(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : const ImagePlaceholder(
                        loading: true,
                        height: 360,
                        width: double.infinity,
                      ),
                Positioned(
                  left: 16,
                  top: 48,
                  child: IconButton.filled(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.keyboard_arrow_left_rounded),
                  ),
                ),
              ],
            ),
            UserProfile(userModel: widget.userModel),
          ],
        ),
      ),
    );
  }
}
