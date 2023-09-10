import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/auth_provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  void _showAuthSnackBar(AuthProvider provider) {
    switch (provider.status) {
      case AuthStatus.authenticateCanceled:
        // TODO: Update design of snackbar for warning
        final snackBar = SnackBar(
          showCloseIcon: true,
          content: Text(provider.message),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        break;

      case AuthStatus.authenticateError:
        // TODO: Update design of snackbar for errors
        final snackBar = SnackBar(
          showCloseIcon: true,
          duration: const Duration(seconds: 10),
          content: Text(provider.message),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        break;
      default:
      //
    }
  }

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
      body: Column(
        children: <Widget>[
          Center(
            child: TextButton(
              onPressed: () async {
                await authProvider.handleSignIn(SocialAuthProvider.google);

                _showAuthSnackBar(authProvider);
              },
              child: const Text('Sign in with Google'),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () async {
                await authProvider.handleSignIn(SocialAuthProvider.facebook);

                _showAuthSnackBar(authProvider);
              },
              child: const Text('Sign in with Facebook'),
            ),
          ),
        ],
      ),
    );
  }
}
