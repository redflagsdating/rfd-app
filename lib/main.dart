import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'services/firebase_options.dart';

void main() async {
  // Ensure binding is initialized before runApp() for Firebase.initializeApp()
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferences localStorage = await SharedPreferences.getInstance();

  runApp(App(localStorage: localStorage));
}
