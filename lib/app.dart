import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/auth_provider.dart';
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
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            localStorage: localStorage,
            firestore: firestore,
          ),
        )
      ],
      // Automatically switch to material or cupertino base on the platform
      child: PlatformProvider(
        builder: (context) {
          AuthProvider authProvider = Provider.of<AuthProvider>(context);

          return PlatformApp(
            home: ListenableBuilder(
              listenable: authProvider,
              // TODO: Page transition animation
              builder: (context, __) {
                if (authProvider.status != AuthStatus.authenticated) {
                  return const SignInPage();
                }

                return const MyHomePage(title: 'Red Flags Dating');
              },
            ),
            // Android app
            material: (_, __) => MaterialAppData(
              color: Colors.greenAccent,
              theme: ThemeData(
                appBarTheme: const AppBarTheme(centerTitle: true),
                colorScheme:
                    ColorScheme.fromSeed(seedColor: Colors.red.shade200),
                useMaterial3: true,
              ),
            ),
            // iOS app
            cupertino: (_, __) => CupertinoAppData(
              theme: const CupertinoThemeData(
                barBackgroundColor: CupertinoColors.systemRed,
                scaffoldBackgroundColor: CupertinoColors.white,
              ),
            ),
          );
        },
      ),
    );
  }
}
