import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/pages/page_home.dart';
import 'package:red_flags/pages/page_onboard_home.dart';
import 'package:red_flags/pages/page_signin.dart';
import 'package:red_flags/pages/page_signin_intro.dart';
import 'package:red_flags/pages/page_signin_splash.dart';
import 'package:red_flags/services/auth_provider.dart';
import 'package:red_flags/services/fire_storage_provider.dart';
import 'package:red_flags/services/logger_provider.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/theme/chip_theme.g.dart';
import 'package:red_flags/theme/color_schemes.g.dart';
import 'package:red_flags/theme/typography_theme.g.dart';
import 'package:red_flags/widgets/animation/slide_transition_switcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App extends StatelessWidget {
  final SharedPreferences localStorage;

  const App({super.key, required this.localStorage});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<SharedPreferences>(create: (_) => localStorage),
        Provider<LoggerProvider>(
          create: (_) => LoggerProvider(),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(
            usersRef: usersRef,
            localStorage: localStorage,
            logger: context.read<LoggerProvider>().logger,
          ),
        ),
        Provider<FireStorageProvider>(
          create: (context) => FireStorageProvider(
            userProvider: context.read<UserProvider>(),
          ),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            localStorage: localStorage,
            gSignIn: GoogleSignIn(),
            fbSignIn: FacebookAuth.instance,
            firebaseAuth: FirebaseAuth.instance,
            userProvider: context.read<UserProvider>(),
            logger: context.read<LoggerProvider>().logger,
          ),
        )
      ],
      // Automatically switch to material or cupertino base on the platform
      child: Builder(
        builder: (context) {
          final authProvider = Provider.of<AuthProvider>(context);

          return FlavorBanner(
            child: MaterialApp(
              theme: ThemeData(
                fontFamily: 'Nunito',
                textTheme: typographyTheme,
                splashColor: lightColorScheme.primary.withOpacity(0.1),
                appBarTheme: AppBarTheme(
                  backgroundColor: lightColorScheme.background,
                  surfaceTintColor: lightColorScheme.background,
                ),
                highlightColor: lightColorScheme.primary.withOpacity(0.1),
                inputDecorationTheme: const InputDecorationTheme(
                  hintStyle: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                    color: Colors.black26,
                  ),
                ),
                badgeTheme: BadgeThemeData(
                  textColor: lightColorScheme.onTertiary,
                  backgroundColor: darkColorScheme.tertiary,
                ),
                outlinedButtonTheme: OutlinedButtonThemeData(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: lightColorScheme.primary),
                  ),
                ),
                floatingActionButtonTheme: FloatingActionButtonThemeData(
                  foregroundColor: lightColorScheme.onPrimary,
                  backgroundColor: lightColorScheme.primary,
                ),
                snackBarTheme: SnackBarThemeData(
                  contentTextStyle: const TextStyle(
                    fontFamily: "Roboto",
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
                chipTheme: chipTheme,
                colorScheme: lightColorScheme,
                useMaterial3: true,
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: CupertinoPageTransitionsBuilder()
                  },
                ),
              ),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: const [Locale('en')],
              home: ListenableBuilder(
                listenable: authProvider,
                builder: (context, __) {
                  final showIntro =
                      !(localStorage.getBool(sharedPrefKey) ?? false);
                  final isOnboard =
                      localStorage.getBool(UserFields.onboarded.name) ?? false;

                  return SlideTransitionSwitcher(
                    reverse: !authProvider.isAuthenticated() &&
                            !authProvider.isAuthenticating()
                        ? true
                        : false,
                    child: authProvider.isAuthenticated()
                        ? (isOnboard
                            ? const PageHome()
                            : const PageOnboardHome())
                        : authProvider.isAuthenticating()
                            ? PageSignInSplash(authProvider: authProvider)
                            : PageSignIn(showIntro: showIntro),
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
