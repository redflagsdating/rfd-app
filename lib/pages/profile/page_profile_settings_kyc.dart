import 'package:flutter/material.dart';
import 'package:red_flags/widgets/profile/profile_kyc.dart';
import 'package:red_flags/widgets/scaffold_page_basic.dart';

class PageProfileSettingsKyc extends StatefulWidget {
  const PageProfileSettingsKyc({super.key, this.title});

  final Widget? title;

  @override
  State<PageProfileSettingsKyc> createState() => _PageProfileSettingsKycState();
}

class _PageProfileSettingsKycState extends State<PageProfileSettingsKyc> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPageBasic(
      title: widget.title,
      content: const ProfileKyc(),
      onBackPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
}
