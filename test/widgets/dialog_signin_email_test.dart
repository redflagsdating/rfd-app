import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:red_flags/services/auth_provider.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/dialog_signin_email.dart';

import '../global.dart' as global;

void main() {
  testWidgets('DialogSigninEmail widget test', (WidgetTester tester) async {
    const closeKey = Key("dialog_email_signin_close");
    const inputKey = Key("dialog_email_signin_input");
    const sendKey = Key("dialog_email_signin_send");

    final authProvider = AuthProvider(
      gSignIn: MockGoogleSignIn(),
      firebaseAuth: MockFirebaseAuth(),
      logger: global.loggerProvider.logger,
      userProvider: UserProvider(
        localStorage: global.localStorage,
        logger: global.loggerProvider.logger,
        usersRef: global.fakeUsersRef,
      ),
      localStorage: global.localStorage,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [Locale('en')],
        home: DialogSigninEmail(authProvider: authProvider),
      ),
    );

    // Verify elements
    expect(find.byKey(closeKey), findsOneWidget);
    expect(find.text(global.l10n.pgSignInEmailTitle), findsOneWidget);
    expect(find.byKey(inputKey), findsOneWidget);
    expect(find.text(global.l10n.pgSignInEmailSendBtn), findsOneWidget);

    // Verify empty email input
    expect(find.text(global.l10n.pgSignInEmailEmpty), findsNothing);
    await tester.tap(find.byKey(sendKey));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(global.l10n.pgSignInEmailEmpty), findsOneWidget);

    // Verify invalid email input
    await tester.enterText(find.byKey(inputKey), "invalid.email");
    await tester.tap(find.byKey(sendKey));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(global.l10n.pgSignInEmailInvalid), findsOneWidget);

    // Verify valid email input
    await tester.enterText(find.byKey(inputKey), "example@email.com");
    await tester.tap(find.byKey(sendKey));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(global.l10n.pgSignInEmailEmpty), findsNothing);
    expect(find.text(global.l10n.pgSignInEmailInvalid), findsNothing);
  });
}
