import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/logger_provider.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/banner_user.dart';

import '../global.dart' as global;

void main() {
  late Widget widget;

  setUp(() async {
    widget = MultiProvider(
      providers: [
        Provider<LoggerProvider>(
          create: (_) => global.loggerProvider,
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(
            localStorage: global.localStorage,
            logger: global.loggerProvider.logger,
            usersRef: global.fakeUsersRef,
          ),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [Locale('en')],
        home: BannerUser(userModel: global.userModel),
      ),
    );
  });

  testWidgets("UserProfileBanner", (widgetTester) async {
    await widgetTester.pumpWidget(widget);
    await widgetTester.pump();
    final age = global.userProvider.getAge(global.userModel.dob!).toString();

    expect(find.text('${global.userModel.displayName!},'), findsOneWidget);
    expect(find.text(age), findsOneWidget);
    expect(find.byIcon(Icons.location_on_rounded), findsOneWidget);
    expect(find.textContaining('0 ${global.l10n.kilometer}'), findsOne);
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.text(global.userModel.locality!), findsOneWidget);
  });
}
