import 'package:flutter/material.dart';
import 'package:red_flags/services/auth_provider.dart';
import 'package:red_flags/widgets/scaffold_branding.dart';

class PageSignInSplash extends StatefulWidget {
  const PageSignInSplash({super.key, required this.authProvider});
  final AuthProvider authProvider;

  @override
  State<PageSignInSplash> createState() => _PageSignInSplashState();
}

class _PageSignInSplashState extends State<PageSignInSplash>
    with TickerProviderStateMixin {
  late void Function() _authListener;
  late ScaffoldMessengerState _scaffoldMessenger;

  @override
  void initState() {
    _authListener = () {
      if (widget.authProvider.message.isNotEmpty) {
        _scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(widget.authProvider.message),
          ),
        );
      }
    };
    widget.authProvider.addListener(_authListener);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _scaffoldMessenger = ScaffoldMessenger.of(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _scaffoldMessenger.clearSnackBars();
    widget.authProvider.removeListener(_authListener);
    super.dispose();
  }

  @override
  Widget build(context) {
    return ScaffoldBranding(
      decoration: const AssetImage("assets/signin-splash-bg.jpg"),
      content: const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: CircularProgressIndicator(
          strokeCap: StrokeCap.round,
          color: Colors.white38,
        ),
      ),
    );
  }
}
