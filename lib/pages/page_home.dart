import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:red_flags/pages/profile/page_profile_settings.dart';
import 'package:red_flags/widgets/animation/slide_transition_switcher.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  bool _reverse = false;
  int _currentIndex = 1;

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
                : Container(
                    key: bodyKey,
                    alignment: Alignment.center,
                    child: Text(l10n!.home),
                  ),
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
