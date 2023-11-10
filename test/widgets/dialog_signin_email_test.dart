import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/services/auth_provider.dart';
import 'package:red_flags/services/logger_provider.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/dialog_signin_email.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('DialogSigninEmail widget test', (WidgetTester tester) async {
    const closeKey = Key("dialog_email_signin_close");
    const inputKey = Key("dialog_email_signin_input");
    const sendKey = Key("dialog_email_signin_send");

    // AuthProvider required
    SharedPreferences.setMockInitialValues({});
    SharedPreferences.setPrefix("red.flags.dev");

    // Load l10n strings
    final l10n = await AppLocalizations.delegate.load(const Locale("en"));

    final localStorage = await SharedPreferences.getInstance();
    final logger = LoggerProvider(silent: true).logger;
    final fakeUsersRef =
        FakeFirebaseFirestore().collection('users').withConverter<UserModel>(
              fromFirestore: (snapshots, _) =>
                  UserModel.fromJson(snapshots.data()!),
              toFirestore: (user, _) => user.toJson(),
            );

    final authProvider = AuthProvider(
      gSignIn: MockGoogleSignIn(),
      firebaseAuth: MockFirebaseAuth(),
      logger: logger,
      userProvider: UserProvider(
        localStorage: localStorage,
        logger: logger,
        mockUsersRef: fakeUsersRef,
      ),
      localStorage: localStorage,
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
    expect(find.text(l10n.pgSignInEmailTitle), findsOneWidget);
    expect(find.byKey(inputKey), findsOneWidget);
    expect(find.text(l10n.pgSignInEmailSendBtn), findsOneWidget);

    // Verify empty email input
    expect(find.text(l10n.pgSignInEmailEmpty), findsNothing);
    await tester.tap(find.byKey(sendKey));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(l10n.pgSignInEmailEmpty), findsOneWidget);

    // Verify invalid email input
    await tester.enterText(find.byKey(inputKey), "invalid.email");
    await tester.tap(find.byKey(sendKey));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(l10n.pgSignInEmailInvalid), findsOneWidget);

    // Verify valid email input
    await tester.enterText(find.byKey(inputKey), "example@email.com");
    await tester.tap(find.byKey(sendKey));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text(l10n.pgSignInEmailEmpty), findsNothing);
    expect(find.text(l10n.pgSignInEmailInvalid), findsNothing);
  });
}
