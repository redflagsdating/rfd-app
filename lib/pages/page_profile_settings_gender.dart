import 'package:flutter/material.dart';
import 'package:red_flags/widgets/profile/profile_gender.dart';
import 'package:red_flags/widgets/scaffold_page_basic.dart';

class PageProfileSettingsGender extends StatefulWidget {
  const PageProfileSettingsGender({Key? key, this.title}) : super(key: key);
  final Widget? title;

  @override
  State<PageProfileSettingsGender> createState() =>
      _PageProfileSettingsGenderState();
}

class _PageProfileSettingsGenderState extends State<PageProfileSettingsGender> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPageBasic(
      title: widget.title,
      content: const ProfileGender(enabled: true, required: true),
      onBackPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
}
