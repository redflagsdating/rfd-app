import 'package:flutter/material.dart';
import 'package:red_flags/widgets/profile/profile_gender.dart';
import 'package:red_flags/widgets/scaffold_page_basic.dart';

class PageProfileSettingsGender extends StatefulWidget {
  const PageProfileSettingsGender({Key? key, this.title, this.genderFor})
      : super(key: key);
  final Widget? title;
  final bool? genderFor;

  @override
  State<PageProfileSettingsGender> createState() =>
      _PageProfileSettingsGenderState();
}

class _PageProfileSettingsGenderState extends State<PageProfileSettingsGender> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPageBasic(
      title: widget.title,
      content: ProfileGender(
        enabled: true,
        required: true,
        genderFor: widget.genderFor,
      ),
      onBackPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
}
