import 'package:flutter/material.dart';
import 'package:red_flags/services/auth_provider.dart';
import 'package:red_flags/widgets/scaffold_signin.dart';

class PageSignInSplash extends StatefulWidget {
  const PageSignInSplash({super.key, required this.authProvider});
  final AuthProvider authProvider;

  @override
  State<PageSignInSplash> createState() => _PageSignInSplashState();
}

class _PageSignInSplashState extends State<PageSignInSplash>
    with TickerProviderStateMixin {
  late AnimationController _animationCtrl;
  late void Function() _authListener;

  @override
  void initState() {
    _authListener = () {
      if (widget.authProvider.message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.authProvider.message),
          ),
        );
      }
    };
    widget.authProvider.addListener(_authListener);

    _animationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(
        () {
          setState(() {});
        },
      );

    _animationCtrl.repeat(reverse: false);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _animationCtrl.dispose();
    widget.authProvider.removeListener(_authListener);
    super.dispose();
  }

  @override
  Widget build(context) {
    return ScaffoldSignIn(
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
