import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:red_flags/services/auth_provider.dart';
import 'package:red_flags/services/logger_provider.dart';
import 'package:red_flags/widgets/page_signin.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('PageSignIn widget test', (WidgetTester tester) async {
    // const gKey = Key("page_signin_google");
    // const fbKey = Key("page_signin_facebook");
    const emailKey = Key("page_signin_email");

    const dialogKey = Key("dialog_email_signin_title");
    const dialogCloseKey = Key("dialog_email_signin_close");
    // const dialogInputKey = Key("dialog_email_signin_input");
    // const dialogSendKey = Key("dialog_email_signin_send");

    // AuthProvider required
    SharedPreferences.setMockInitialValues({});
    SharedPreferences.setPrefix("red.flags.dev");

    // Load l10n strings
    final l10n = await AppLocalizations.delegate.load(const Locale("en"));

    final logger = LoggerProvider(silent: true).logger;
    final authProvider = AuthProvider(
      gSignIn: MockGoogleSignIn(),
      firebaseAuth: MockFirebaseAuth(
        mockUser: MockUser(
          email: "test@email.com",
          displayName: "Test User",
        ),
      ),
      logger: logger,
      firestore: FakeFirebaseFirestore(),
      localStorage: await SharedPreferences.getInstance(),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [Locale('en')],
        home: PageSignIn(logger: logger, authProvider: authProvider),
      ),
    );

    // Verify elements
    expect(find.text(l10n.pgSignInTagLine), findsOneWidget);
    expect(find.text(l10n.pgSignInWithBtn("Google")), findsOneWidget);
    expect(find.text(l10n.pgSignInWithBtn("Facebook")), findsOneWidget);
    expect(find.text(l10n.pgSignInWithBtn(l10n.email)), findsOneWidget);

    // Verify email sign-in dialog
    expect(find.byKey(dialogKey), findsNothing);
    await tester.tap(find.byKey(emailKey));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(dialogKey), findsOneWidget);
    await tester.tap(find.byKey(dialogCloseKey));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(dialogKey), findsNothing);
  });
}
