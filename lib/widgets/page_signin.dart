import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/auth_provider.dart';
import 'package:red_flags/widgets/mixin_snack_bar.dart';

class PageSignIn extends StatefulWidget {
  const PageSignIn({super.key});

  @override
  State<PageSignIn> createState() => PageSignInState();
}

class PageSignInState extends State<PageSignIn> with MixinSnackBar {
  late AuthProvider authProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    authProvider = Provider.of<AuthProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyPageHome object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Sign in page'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: TextButton(
              onPressed: () {
                authProvider
                    .handleSignIn(SocialAuthProvider.google)
                    .whenComplete(
                        () => showAuthStatusSnackBar(context, authProvider));
              },
              child: const Text('Sign in with Google'),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {
                authProvider
                    .handleSignIn(SocialAuthProvider.facebook)
                    .whenComplete(
                        () => showAuthStatusSnackBar(context, authProvider));
              },
              child: const Text('Sign in with Facebook'),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () async {
                Navigator.pushNamed(context, '/signin-email');
              },
              child: const Text('Sign in with Email'),
            ),
          ),
        ],
      ),
    );
  }
}
