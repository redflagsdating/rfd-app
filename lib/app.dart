import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'home.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Automatically switch to material or cupertino base on the platform
    return PlatformProvider(
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
    );
  }
}
