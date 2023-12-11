import 'package:flutter/material.dart';
import 'package:red_flags/widgets/profile/profile_photos.dart';
import 'package:red_flags/widgets/scaffold_page_basic.dart';

class PageProfileSettingsPhotos extends StatefulWidget {
  const PageProfileSettingsPhotos({Key? key, this.title}) : super(key: key);
  final Widget? title;

  @override
  State<PageProfileSettingsPhotos> createState() =>
      _PageProfileSettingsPhotosState();
}

class _PageProfileSettingsPhotosState extends State<PageProfileSettingsPhotos> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPageBasic(
      title: widget.title,
      content: const ProfilePhotos(enabled: true),
      onBackPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
}
