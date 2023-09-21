import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/auth_provider.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => PageHomeState();
}

class PageHomeState extends State<PageHome> {
  late AuthProvider authProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    authProvider = Provider.of<AuthProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Center(
            child: TextButton(
              onPressed: () async {
                await authProvider.handleSignOut();
              },
              child: Text(AppLocalizations.of(context)!.signOut),
            ),
          )
        ],
      ),
    );
  }
}
