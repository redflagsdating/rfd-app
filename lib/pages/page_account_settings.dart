import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/mixins/mixin_file.dart';
import 'package:red_flags/pages/page_account_locality.dart';
import 'package:red_flags/services/auth_provider.dart';
import 'package:red_flags/services/fire_storage_provider.dart';
import 'package:red_flags/services/logger_provider.dart';
import 'package:red_flags/services/user_provider.dart';

class PageAccountSettings extends StatefulWidget {
  const PageAccountSettings({Key? key}) : super(key: key);

  @override
  State<PageAccountSettings> createState() => _PageAccountSettingsState();
}

class _PageAccountSettingsState extends State<PageAccountSettings>
    with MixinFile {
  Future<File?> _fetchAvatar() async {
    File? avatarImgFile;

    final userProvider = context.read<UserProvider>();
    final storageProvider = context.read<FireStorageProvider>();
    final photoUrl = await userProvider.getPhotoUrl();

    if (photoUrl != null) {
      avatarImgFile = await createFileObject(photoUrl);

      /// Download photo from Firebase storage when photo is cached at local,
      /// such as logged in on a different device.
      if (avatarImgFile.lengthSync() == 0) {
        return storageProvider.rootRef
            .child(photoUrl)
            .writeToFile(avatarImgFile)
            .whenComplete(() => avatarImgFile)
            .then((value) => avatarImgFile);
      } else {
        return avatarImgFile;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final logger = context.read<LoggerProvider>().logger;
    final authProvider = context.read<AuthProvider>();
    final menuItems = [
      {
        "icon": const Icon(Icons.person_outline_rounded, size: 28),
        "label": l10n!.pgAccountMenuProfile,
      },
      {
        "icon": const Icon(Icons.badge_outlined, size: 28),
        "label": l10n.pgAccountMenuVerify
      },
      {
        "icon": const Icon(Icons.location_on_rounded, size: 28),
        "label": l10n.pgAccountMenuLocation,
        "page": PageAccountLocality(
          title: Text(
            l10n.pgAccountMenuLocation,
            style: theme.textTheme.titleMedium,
          ),
        ),
      },
      {
        "icon": const Icon(Icons.error_outline_sharp, size: 28),
        "label": l10n.pgAccountMenuReport
      },
      {
        "icon": const Icon(Icons.support_agent_outlined, size: 28),
        "label": l10n.pgAccountMenuSupport
      },
      {
        "icon": const Icon(Icons.chat_bubble_outline, size: 28),
        "label": l10n.pgAccountMenuFaq
      },
      {
        "icon": const Icon(Icons.bubble_chart, size: 28),
        "label": l10n.pgAccountMenuLegal
      },
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      color: theme.colorScheme.inversePrimary.withOpacity(0.2),
      alignment: Alignment.center,
      child: Column(
        children: [
          const SizedBox(height: 32),
          ListenableBuilder(
            listenable: userProvider,
            builder: (context, _) {
              final verifySubmitted = userProvider.getVerifySubmittedCache();

              return Badge(
                largeSize: 32,
                backgroundColor: theme.colorScheme.onSecondary.withOpacity(0.8),
                alignment: Alignment.bottomRight,
                label: verifySubmitted != true
                    ? const Icon(
                        Icons.person_search,
                        color: Colors.black26,
                      )
                    : FutureBuilder(
                        future: userProvider.getVerified(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return snapshot.data == true
                                ? Icon(
                                    Icons.verified,
                                    color: Colors.green.shade400,
                                  )
                                : snapshot.data == false
                                    ? Icon(
                                        Icons.cancel,
                                        color: theme.colorScheme.error,
                                      )
                                    : Icon(
                                        Icons.access_time_filled_rounded,
                                        color: theme.colorScheme.tertiary,
                                      );
                          }

                          return Icon(
                            Icons.circle_outlined,
                            color:
                                theme.colorScheme.onSecondary.withOpacity(0.8),
                          );
                        },
                      ),
                child: FutureBuilder(
                  future: _fetchAvatar(),
                  builder: (context, snapshot) {
                    final file = snapshot.data;
                    return snapshot.hasData && file != null
                        ? CircleAvatar(
                            maxRadius: 60,
                            minRadius: 60,
                            backgroundImage: FileImage(file),
                            onBackgroundImageError: (exception, stackTrace) {
                              logger.e(exception, time: DateTime.now());
                            },
                          )
                        : CircleAvatar(
                            maxRadius: 60,
                            minRadius: 60,
                            backgroundColor: theme.colorScheme.outlineVariant
                                .withOpacity(0.2),
                            child: Icon(
                              Icons.person,
                              color: theme.colorScheme.outlineVariant
                                  .withOpacity(0.6),
                              size: 60,
                            ),
                          );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          ListenableBuilder(
            listenable: userProvider,
            builder: (context, _) {
              final firstName = userProvider.getFirstNameCache();
              final lastName = userProvider.getLastNameCache();

              return Text(
                '$firstName $lastName',
                style: theme.textTheme.titleLarge,
              );
            },
          ),
          const SizedBox(height: 2),
          OutlinedButton(
            onPressed: () {
              // TODO
            },
            child: Text(l10n.pgAccountViewProfileBtn),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
                width: double.infinity,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: theme.colorScheme.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      return Material(
                        child: InkWell(
                          onTap: () {
                            final page = menuItems[index]['page'];

                            if (page is Widget) {
                              Future.delayed(const Duration(milliseconds: 150),
                                  () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => page,
                                  ),
                                );
                              });
                            }
                          },
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                menuItems[index]['icon'] as Widget,
                                const SizedBox(width: 10),
                                Text(
                                  menuItems[index]['label'] as String,
                                  style: theme.textTheme.labelLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )),
          ),
          TextButton(
            onPressed: () {
              authProvider.handleSignOut();
              setState(() {});
            },
            child: Text(l10n.logout),
          )
        ],
      ),
    );
  }
}
