import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/auth_provider.dart';
import 'package:red_flags/services/logger_provider.dart';
import 'package:red_flags/widgets/page_home.dart';
import 'package:red_flags/widgets/page_signin.dart';
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

          return FlavorBanner(
            child: MaterialApp(
              routes: <String, WidgetBuilder>{
                '/signin': (context) {
                  return const PageSignIn();
                }
              },
              theme: ThemeData(
                fontFamily: 'Nunito',
                textTheme: const TextTheme(
                  bodyLarge: TextStyle(fontFamily: 'LeagueSpartan'),
                  bodyMedium: TextStyle(fontFamily: 'LeagueSpartan'),
                  bodySmall: TextStyle(fontFamily: 'LeagueSpartan'),
                ),
                // primarySwatch: Colors.,
                colorScheme: const ColorScheme(
                  brightness: Brightness.light,
                  primary: Color.fromRGBO(255, 0, 73, 1.0),
                  onPrimary: Colors.white,
                  primaryContainer: Color.fromRGBO(255, 189, 228, 1.0),
                  onPrimaryContainer: Color.fromRGBO(27, 20, 100, 1.0),
                  secondary: Color.fromRGBO(255, 189, 228, 1.0),
                  onSecondary: Colors.white,
                  secondaryContainer: Color.fromRGBO(255, 189, 228, 1.0),
                  onSecondaryContainer: Color.fromRGBO(27, 20, 100, 1.0),
                  tertiaryContainer: Color.fromRGBO(179, 234, 255, 1.0),
                  onTertiaryContainer: Color.fromRGBO(27, 20, 100, 1.0),
                  error: Color.fromRGBO(175, 16, 0, 1.0),
                  onError: Colors.white,
                  background: Colors.white,
                  onBackground: Colors.black,
                  surface: Color.fromRGBO(255, 189, 228, 1.0),
                  onSurface: Color.fromRGBO(27, 20, 100, 1.0),
                ),
                buttonTheme: const ButtonThemeData(),
                useMaterial3: true,
              ),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: const [Locale('en')],
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
                    child:
                        isAuthenticated ? const PageHome() : const PageSignIn(),
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
