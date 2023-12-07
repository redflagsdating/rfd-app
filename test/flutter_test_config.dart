import 'dart:async';
import 'dart:ui';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './global.dart' as global;

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    SharedPreferences.setPrefix("red.flags.test");

    // Initialize global late variables
    global.l10n = await AppLocalizations.delegate.load(const Locale("en"));
    global.localStorage = await SharedPreferences.getInstance();
    global.userProvider = UserProvider(
      usersRef: global.fakeUsersRef,
      localStorage: global.localStorage,
      logger: global.loggerProvider.logger,
    );
  });

  tearDown(() {});

  await testMain();
}
