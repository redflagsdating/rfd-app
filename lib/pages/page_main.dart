import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/mixins/mixin_kyc_state.dart';
import 'package:red_flags/mixins/mixin_permissions.dart';
import 'package:red_flags/pages/home/page_home.dart';
import 'package:red_flags/pages/profile/page_profile_settings.dart';
import 'package:red_flags/pages/profile/page_profile_settings_kyc.dart';
import 'package:red_flags/services/logger_provider.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/animation/slide_transition_switcher.dart';

class PageMain extends StatefulWidget {
  const PageMain({super.key});

  @override
  State<PageMain> createState() => _PageMainState();
}

class _PageMainState extends State<PageMain>
    with MixinKycState, MixinPermissions {
  bool _reverse = false;
  int _currentIndex = 1;

  @override
  void initState() {
    updateKycStatus();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _showKycBanner();
      await requestNotificationPermissions();
    });

    // Update user's FCM token on refreshed
    FirebaseMessaging.instance.onTokenRefresh.listen(
      (fcmToken) {
        context.read<UserProvider>().updateFcmToken(fcmToken);
      },
    ).onError(
      (err) {
        context.read<LoggerProvider>().logger.e(err, time: DateTime.now());
      },
    );
    super.initState();
  }

  void _showKycBanner() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final isSubmitted = context.read<UserProvider>().getVerifySubmittedCache();

    if (isSubmitted != true) {
      scaffoldMessenger.showMaterialBanner(
        MaterialBanner(
          content: Text(
            l10n!.pgHomeKycBanner,
          ),
          leading: Icon(
            Icons.verified_rounded,
            color: theme.colorScheme.onSecondary,
          ),
          actions: [
            FilledButton.tonal(
              onPressed: () {
                scaffoldMessenger.clearMaterialBanners();

                Future.delayed(const Duration(milliseconds: 300)).whenComplete(
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PageProfileSettingsKyc(
                          title: Text(
                            l10n.verification,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: Text(l10n.verify),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    // For animation mainly
    final bodyKey = ValueKey(_currentIndex);

    return Scaffold(
      body: SlideTransitionSwitcher(
        reverse: _reverse,
        child: _currentIndex == 0
            ? Container(
                key: bodyKey,
                alignment: Alignment.center,
                child: Text(l10n!.calendar),
              )
            : _currentIndex == 2
                ? PageProfileSettings(key: bodyKey)
                : PageHome(key: bodyKey),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _currentIndex,
        unselectedItemColor: theme.colorScheme.primary.withOpacity(0.2),
        selectedIconTheme: IconThemeData(
          shadows: [
            Shadow(
              color: theme.colorScheme.outlineVariant,
              offset: const Offset(0, 1),
              // blurRadius: 2,
            )
          ],
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.calendar_month,
              semanticLabel: l10n!.calendar,
            ),
            label: l10n.calendar,
          ),
          BottomNavigationBarItem(
            activeIcon: Image.asset(
              "assets/rf-logo-red.png",
              width: 52,
              semanticLabel: l10n.home,
            ),
            icon: Image.asset(
              "assets/rf-logo-red.png",
              width: 52,
              semanticLabel: l10n.home,
              opacity: const AlwaysStoppedAnimation(.2),
            ),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.perm_contact_cal_rounded,
              semanticLabel: l10n.profile,
            ),
            label: l10n.profile,
          ),
        ],
        onTap: (index) {
          // TODO: Temporary disable it
          if (index == 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('The Book A Date feature is coming soon!'),
              ),
            );
            return;
          }

          if (_currentIndex != index) {
            setState(() {
              _reverse = index < _currentIndex;
              _currentIndex = index;
            });
          }
        },
      ),
    );
  }
}
