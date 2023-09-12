import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/auth_provider.dart';
import 'package:red_flags/services/logger_provider.dart';
import 'package:red_flags/widgets/home_page.dart';
import 'package:red_flags/widgets/signin_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App extends StatelessWidget {
  final SharedPreferences localStorage;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  // final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  App({super.key, required this.localStorage});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LoggerProvider>(
          create: (_) => LoggerProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            localStorage: localStorage,
            firestore: firestore,

            /// Need to set "listen: false" in order to call Provider.of inside
            /// create method.
            /// See https://pub.dev/documentation/provider/latest/provider/Provider/of.html
            logger: Provider.of<LoggerProvider>(context, listen: false).logger,
          ),
        )
      ],
      // Automatically switch to material or cupertino base on the platform
      child: Builder(
        builder: (context) {
          AuthProvider authProvider = Provider.of<AuthProvider>(context);

          return MaterialApp(
            theme: ThemeData(
              appBarTheme: const AppBarTheme(centerTitle: true),
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.red.shade200),
              useMaterial3: true,
            ),
            home: ListenableBuilder(
              listenable: authProvider,
              builder: (context, __) {
                final isAuthenticated =
                    authProvider.status == AuthStatus.authenticated;
                final offset = isAuthenticated
                    ? Tween(begin: const Offset(1, 0.0), end: Offset.zero)
                    : Tween(begin: const Offset(-1, 0.0), end: Offset.zero);

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  reverseDuration: const Duration(milliseconds: 0),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: (offset).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: isAuthenticated
                      ? const MyHomePage(title: 'Red Flags Dating')
                      : const SignInPage(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
