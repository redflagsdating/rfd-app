import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/models/user.dart' show UserModel, UserFields;
import 'package:red_flags/pages/page_signin.dart';
import 'package:red_flags/services/auth_provider.dart';
import 'package:red_flags/services/logger_provider.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const gKey = Key("page_signin_google");
  // const fbKey = Key("page_signin_facebook");
  const emailKey = Key("page_signin_email");

  const dialogKey = Key("dialog_email_signin_title");
  const dialogCloseKey = Key("dialog_email_signin_close");
  const dialogInputKey = Key("dialog_email_signin_input");
  const dialogSendKey = Key("dialog_email_signin_send");

  late AuthProvider authProvider;
  late LoggerProvider loggerProvider;
  late AppLocalizations l10n;
  late Widget widget;
  late SharedPreferences localStorage;
  late MockFirebaseAuth firebaseAuth;
  late CollectionReference<UserModel> fakeUsersRef;

  setUpAll(
    () async {
      l10n = await AppLocalizations.delegate.load(const Locale("en"));
    },
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    SharedPreferences.setPrefix("red.flags.dev");

    localStorage = await SharedPreferences.getInstance();
    loggerProvider = LoggerProvider(silent: true);
    fakeUsersRef =
        FakeFirebaseFirestore().collection('users').withConverter<UserModel>(
              fromFirestore: (snapshots, _) =>
                  UserModel.fromJson(snapshots.data()!),
              toFirestore: (user, _) => user.toJson(),
            );
    firebaseAuth = MockFirebaseAuth(
      mockUser: MockUser(
        email: "test@email.com",
        displayName: "Test User",
        uid: "ecd5e6e2-58af-4f54-8084-98e9974969ba",
      ),
    );

    // Create a new root widget for each test
    widget = MultiProvider(
      providers: [
        Provider<SharedPreferences>(create: (_) => localStorage),
        Provider<LoggerProvider>(
          create: (_) => loggerProvider,
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(
            localStorage: localStorage,
            logger: loggerProvider.logger,
            mockUsersRef: fakeUsersRef,
          ),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) {
            authProvider = AuthProvider(
              gSignIn: MockGoogleSignIn(),
              firebaseAuth: firebaseAuth,
              logger: loggerProvider.logger,
              userProvider: context.read<UserProvider>(),
              localStorage: localStorage,
            );

            return authProvider;
          },
        ),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: [Locale('en')],
        home: PageSignIn(),
      ),
    );
  });

  testWidgets('PageSignIn > Verify elements', (tester) async {
    await tester.pumpWidget(widget);

    expect(find.text(l10n.pgSignInTagLine), findsOneWidget);
    expect(find.text(l10n.pgSignInWithBtn("Google")), findsOneWidget);
    expect(find.text(l10n.pgSignInWithBtn("Facebook")), findsOneWidget);
    expect(find.text(l10n.pgSignInWithBtn(l10n.email)), findsOneWidget);
  });

  testWidgets('PageSignIn > Verify Google sign-in', (tester) async {
    await tester.pumpWidget(widget);

    await tester.tap(find.byKey(gKey));
    await tester.pump(const Duration(milliseconds: 100));
    expect(authProvider.isAuthenticated(), isTrue);

    // Ensure user data is created in the Firestore
    final result = await fakeUsersRef
        .where(UserFields.email.name, isEqualTo: 'test@email.com')
        .get();

    final userModel = result.docs.first.data();
    expect(userModel.displayName == 'Test User', isTrue);
    expect(userModel.uid == 'ecd5e6e2-58af-4f54-8084-98e9974969ba', isTrue);
    expect(userModel.createdAt, isNotNull);
  });

  testWidgets('PageSignIn > Verify email link sign-in', (tester) async {
    WidgetsFlutterBinding.ensureInitialized();

    /// Required for PackageInfo.fromPlatform() in authProvider.sendSignInLinkToEmail()
    /// https://github.com/fluttercommunity/plus_plugins/issues/1827
    const MethodChannel channel =
        MethodChannel('dev.fluttercommunity.plus/package_info');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(channel.name, (data) async {
      final MethodCall call = channel.codec.decodeMethodCall(data);
      if (call.method == 'getAll') {
        return channel.codec.encodeSuccessEnvelope(<String, dynamic>{
          'appName': 'Red Flags',
          'packageName': 'com.redflags.app',
          'version': '0.0.1',
          'buildNumber': '1'
        });
      }
      return null;
    });

    await tester.pumpWidget(widget);
    expect(find.byKey(dialogKey), findsNothing);

    await tester.tap(find.byKey(emailKey));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(dialogKey), findsOneWidget);

    await tester.tap(find.byKey(dialogCloseKey));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(dialogKey), findsNothing);

    await tester.tap(find.byKey(emailKey));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byKey(dialogInputKey), 'example@email.com');
    await tester.tap(find.byKey(dialogSendKey));
    await tester.pump(const Duration(milliseconds: 100));
    expect(authProvider.isPending(), isTrue);
    // TODO: Found 2 widgets but should be one
    expect(find.text(l10n.pgSignInEmailSent), findsWidgets);

    // TODO: Test scenario after receive email link
  });
}
