import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/mixins/mixin_file.dart';
import 'package:red_flags/services/fire_storage_provider.dart';
import 'package:red_flags/services/logger_provider.dart';
import 'package:red_flags/services/user_provider.dart';

class UserCircleAvatar extends StatefulWidget {
  const UserCircleAvatar({super.key});

  @override
  State<UserCircleAvatar> createState() => _UserCircleAvatarState();
}

class _UserCircleAvatarState extends State<UserCircleAvatar> with MixinFile {
  Future<File?> _fetchAvatar() async {
    File? file;

    final userProvider = context.read<UserProvider>();
    final storageProvider = context.read<FireStorageProvider>();
    final photoUrl = await userProvider.getPhotoUrl();

    if (photoUrl != null) {
      file = await createFileObject(photoUrl);

      /// Download photo from Firebase storage when photo is cached at local,
      /// such as logged in on a different device.
      if (file.lengthSync() == 0) {
        return storageProvider.rootRef
            .child(photoUrl)
            .writeToFile(file)
            .whenComplete(() => file)
            .then((value) => file);
      } else {
        return file;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logger = context.read<LoggerProvider>().logger;
    final userProvider = Provider.of<UserProvider>(context);

    return ListenableBuilder(
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
                                  Icons.error,
                                  color: theme.colorScheme.error,
                                )
                              : Icon(
                                  Icons.access_time_filled_rounded,
                                  color: theme.colorScheme.tertiary,
                                );
                    }

                    return Icon(
                      Icons.circle_outlined,
                      color: theme.colorScheme.onSecondary.withOpacity(0.8),
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
                      backgroundColor:
                          theme.colorScheme.outlineVariant.withOpacity(0.2),
                      child: Icon(
                        Icons.person,
                        color:
                            theme.colorScheme.outlineVariant.withOpacity(0.6),
                        size: 60,
                      ),
                    );
            },
          ),
        );
      },
    );
  }
}
