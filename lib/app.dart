import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/color_schemes.g.dart';
import 'package:red_flags/services/auth_provider.dart';
import 'package:red_flags/services/logger_provider.dart';
import 'package:red_flags/typograph_theme.g.dart';
import 'package:red_flags/widgets/page_home.dart';
import 'package:red_flags/widgets/page_signin.dart';
import 'package:red_flags/widgets/page_signin_splash.dart';
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
            gSignIn: GoogleSignIn(),
            fbSignIn: FacebookAuth.instance,
            firebaseAuth: FirebaseAuth.instance,

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
          final logger = Provider.of<LoggerProvider>(context).logger;
          final authProvider = Provider.of<AuthProvider>(context);

          return FlavorBanner(
            child: MaterialApp(
              // routes: <String, WidgetBuilder>{1
              //   '/signin': (context) {
              //     return const PageSignIn();
              //   },
              //   '/signin-splash': (context) {
              //     return const PageSignInSplash();
              //   }
              // },
              theme: ThemeData(
                fontFamily: 'Nunito',
                textTheme: typographyTheme,
                snackBarTheme: SnackBarThemeData(
                  contentTextStyle: const TextStyle(
                    fontFamily: "Roboto",
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
                colorScheme: lightColorScheme,
                useMaterial3: true,
              ),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: const [Locale('en')],
              home: ListenableBuilder(
                listenable: authProvider,
                builder: (context, __) {
                  final isAuthenticated =
                      authProvider.status == AuthStatus.authenticated;
                  final isAuthenticating =
                      authProvider.status == AuthStatus.authenticating;
                  final offset = isAuthenticated || isAuthenticating
                      ? Tween(begin: const Offset(1, 0.0), end: Offset.zero)
                      : Tween(begin: const Offset(-1, 0.0), end: Offset.zero);

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    reverseDuration: const Duration(milliseconds: 0),
                    transitionBuilder: (child, animation) {
                      return SlideTransition(
                        position: animation.drive(offset),
                        child: child,
                      );
                    },
                    child: isAuthenticated
                        ? const PageHome()
                        : isAuthenticating
                            ? PageSignInSplash(authProvider: authProvider)
                            : PageSignIn(
                                logger: logger,
                                authProvider: authProvider,
                              ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
