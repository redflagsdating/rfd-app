import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/pages/profile/page_profile_settings.photos.dart';
import 'package:red_flags/pages/profile/page_profile_settings_age.dart';
import 'package:red_flags/pages/profile/page_profile_settings_display_name.dart';
import 'package:red_flags/pages/profile/page_profile_settings_full_name.dart';
import 'package:red_flags/pages/profile/page_profile_settings_gender.dart';
import 'package:red_flags/pages/profile/page_profile_settings_greenflags.dart';
import 'package:red_flags/pages/profile/page_profile_settings_kyc.dart';
import 'package:red_flags/pages/profile/page_profile_settings_locality.dart';
import 'package:red_flags/pages/profile/page_profile_settings_realtalk.dart';
import 'package:red_flags/pages/profile/page_profile_settings_redflags.dart';
import 'package:red_flags/services/auth_provider.dart';
import 'package:red_flags/widgets/profile/dialog_delete_account.dart';
import 'package:red_flags/widgets/profile/profile_settings_menu.dart';
import 'package:red_flags/widgets/profile/profile_settings_menu_item.dart';
import 'package:red_flags/widgets/user_circle_avatar.dart';
import 'package:red_flags/widgets/user_text_full_name.dart';

class PageProfileSettings extends StatefulWidget {
  const PageProfileSettings({super.key});

  @override
  State<PageProfileSettings> createState() => _PageProfileSettingsState();
}

class _PageProfileSettingsState extends State<PageProfileSettings> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final authProvider = context.read<AuthProvider>();

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        color: theme.colorScheme.inversePrimary.withOpacity(0.2),
        alignment: Alignment.center,
        child: Column(
          children: [
            const SizedBox(height: 32),
            const UserCircleAvatar(),
            const SizedBox(height: 16),
            UserTextFullName(style: theme.textTheme.titleLarge),
            const SizedBox(height: 2),
            FilledButton(
              onPressed: () {
                // TODO
              },
              child: Text(l10n!.pgProfileViewProfileBtn),
            ),
            const SizedBox(height: 24),
            ProfileSettingsMenu(
              title: l10n.pgProfileMenuAboutMeTitle,
              children: [
                ProfileSettingsMenuItem(
                  label: l10n.fullName,
                  leadingIcon: Icons.person,
                  trailingIcon: Icons.arrow_forward_ios_rounded,
                  page: PageProfileSettingsFullName(
                    title: Text(
                      l10n.fullName,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
                ProfileSettingsMenuItem(
                  label: l10n.displayName,
                  leadingIcon: FontAwesomeIcons.signature,
                  trailingIcon: Icons.arrow_forward_ios_rounded,
                  page: PageProfileSettingsDisplayName(
                    title: Text(
                      l10n.displayName,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
                ProfileSettingsMenuItem(
                  label: l10n.gender,
                  leadingIcon: FontAwesomeIcons.marsAndVenus,
                  trailingIcon: Icons.arrow_forward_ios_rounded,
                  page: PageProfileSettingsGender(
                    title: Text(
                      l10n.gender,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
                ProfileSettingsMenuItem(
                  label: l10n.age,
                  leadingIcon: Icons.man,
                  trailingIcon: Icons.arrow_forward_ios_rounded,
                  page: PageProfileSettingsAge(
                    title: Text(
                      l10n.age,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
                ProfileSettingsMenuItem(
                  label: l10n.pgProfileMenuItemLocation,
                  leadingIcon: Icons.location_on_rounded,
                  trailingIcon: Icons.arrow_forward_ios_rounded,
                  page: PageProfileSettingsLocality(
                    title: Text(
                      l10n.pgProfileMenuItemLocation,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
                ProfileSettingsMenuItem(
                  label: l10n.photo(2),
                  leadingIcon: Icons.photo,
                  trailingIcon: Icons.arrow_forward_ios_rounded,
                  page: PageProfileSettingsPhotos(
                    title: Text(
                      l10n.photo(2),
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
                ProfileSettingsMenuItem(
                  label: l10n.verification,
                  leadingIcon: Icons.badge_outlined,
                  trailingIcon: Icons.arrow_forward_ios_rounded,
                  page: PageProfileSettingsKyc(
                    title: Text(
                      l10n.verification,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            ProfileSettingsMenu(
              title: l10n.pgProfileMenuPreferenceTitle,
              children: [
                ProfileSettingsMenuItem(
                  label: l10n.gender,
                  leadingIcon: FontAwesomeIcons.marsAndVenus,
                  trailingIcon: Icons.arrow_forward_ios_rounded,
                  page: PageProfileSettingsGender(
                    genderFor: true,
                    title: Text(
                      l10n.gender,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
                ProfileSettingsMenuItem(
                  label: l10n.brandTagLine,
                  leadingIcon: Icons.question_answer_outlined,
                  trailingIcon: Icons.arrow_forward_ios_rounded,
                  page: PageProfileSettingsRealtalk(
                    title: Text(
                      l10n.brandTagLine,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
                ProfileSettingsMenuItem(
                  label: l10n.brandName,
                  leadingIcon: Icons.flag_circle_sharp,
                  leadingIconColor: theme.colorScheme.primary,
                  trailingIcon: Icons.arrow_forward_ios_rounded,
                  page: PageProfileSettingsRedFlags(
                    title: Text(
                      l10n.brandName,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
                ProfileSettingsMenuItem(
                  label: l10n.pgProfileMenuItemGreenFlags,
                  leadingIcon: Icons.flag_circle_sharp,
                  leadingIconColor: Colors.green,
                  trailingIcon: Icons.arrow_forward_ios_rounded,
                  page: PageProfileSettingsGreenFlags(
                    title: Text(
                      l10n.pgProfileMenuItemGreenFlags,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            ProfileSettingsMenu(
              title: l10n.pgProfileMenuHelpTitle,
              children: [
                ProfileSettingsMenuItem(
                  label: l10n.pgProfileMenuItemReport,
                  leadingIcon: Icons.error_outline_sharp,
                  trailingIcon: Icons.open_in_new,
                ),
                ProfileSettingsMenuItem(
                  label: l10n.pgProfileMenuItemSupport,
                  leadingIcon: Icons.support_agent_outlined,
                  trailingIcon: Icons.open_in_new,
                ),
                ProfileSettingsMenuItem(
                  label: l10n.pgProfileMenuItemFaq,
                  leadingIcon: Icons.chat_bubble_outline,
                  trailingIcon: Icons.open_in_new,
                ),
                ProfileSettingsMenuItem(
                  label: l10n.pgProfileMenuItemLegal,
                  leadingIcon: Icons.policy,
                  trailingIcon: Icons.open_in_new,
                ),
              ],
            ),
            const SizedBox(height: 28),
            ProfileSettingsMenu(
              title: l10n.pgProfileMenuAccountTitle,
              children: [
                ProfileSettingsMenuItem(
                    label: l10n.pgProfileMenuItemSignOut,
                    leadingIcon: Icons.logout,
                    onTap: () async {
                      await authProvider.handleSignOut();
                    }),
                ProfileSettingsMenuItem(
                  label: l10n.pgProfileMenuItemDeleteAccount,
                  labelColor: theme.colorScheme.error,
                  leadingIcon: Icons.delete_forever_rounded,
                  leadingIconColor: theme.colorScheme.error,
                  onTap: () {
                    showGeneralDialog(
                      context: context,
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const DialogDeleteAccount(),
                      transitionBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return SharedAxisTransition(
                          animation: animation,
                          secondaryAnimation: secondaryAnimation,
                          transitionType: SharedAxisTransitionType.vertical,
                          child: child,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
