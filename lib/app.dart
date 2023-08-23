import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widgets/home_page.dart';

class App extends StatelessWidget {
  final SharedPreferences localStorage;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  // final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  App({super.key, required this.localStorage});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            gSignIn: GoogleSignIn(),
            localStorage: localStorage,
            firebaseAuth: FirebaseAuth.instance,
            firebaseFirestore: firebaseFirestore,
          ),
        )
      ],
      // Automatically switch to material or cupertino base on the platform
      child: PlatformProvider(
        builder: (context) => PlatformApp(
          title: 'Red Flags Dating',
          home: const MyHomePage(title: 'Red Flags Dating'),
          // Android app
          material: (_, __) => MaterialAppData(
            color: Colors.greenAccent,
            theme: ThemeData(
              appBarTheme: const AppBarTheme(centerTitle: true),
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.red.shade200),
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
        ),
      ),
    );
  }
}
