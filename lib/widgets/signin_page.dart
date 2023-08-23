import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/providers/auth_provider.dart';

import 'home_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);

    return PlatformScaffold(
      cupertino: (_, __) => CupertinoPageScaffoldData(
          navigationBar: const CupertinoNavigationBar(
        middle: Text('Sign In Page'),
      )),
      appBar: PlatformAppBar(
        title: const Text('Sign In Page'),
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: TextButton(
              onPressed: () async {
                // authProvider.handleSignOut();
                authProvider.handleSignIn().then(
                  (isSuccess) {
                    if (isSuccess) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyHomePage(
                            title: 'Signed Red Flags Dating',
                          ),
                        ),
                      );
                    }
                  },
                );
              },
              child: const Text('Sign in with Google'),
            ),
          )
        ],
      ),
    );
  }
}
