import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/auth_provider.dart';
import 'package:red_flags/services/user_provider.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  File? _img;
  late AuthProvider authProvider;

  void setImageFile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final appDocDir = await getApplicationDocumentsDirectory();
    final spotlightPhoto = userProvider.getPhotoUrlCache();

    // TODO: Download photo url for different devices

    _img = File('${appDocDir.path}/$spotlightPhoto');
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    authProvider = context.read<AuthProvider>();
  }

  @override
  Widget build(BuildContext context) {
    setImageFile();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_img != null)
          Image.file(
            _img as File,
            width: 300,
            height: 300,
            fit: BoxFit.cover,
          ),
        const SizedBox(height: 40),
        FilledButton(
          onPressed: () {
            authProvider.handleSignOut();
          },
          child: Text(AppLocalizations.of(context)!.signOut),
        )
      ],
    );
  }
}
