import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/auth_provider.dart';
import 'package:red_flags/services/fire_storage_provider.dart';
import 'package:red_flags/services/identity_verification.dart';
import 'package:red_flags/services/logger_provider.dart';
import 'package:red_flags/services/user_provider.dart';

class DialogDeleteAccount extends StatefulWidget {
  const DialogDeleteAccount({super.key});

  @override
  State<DialogDeleteAccount> createState() => _DialogDeleteAccountState();
}

class _DialogDeleteAccountState extends State<DialogDeleteAccount>
    with WidgetsBindingObserver {
  bool _enabled = false;
  bool _deleting = false;
  late IdentityVerification _kycApi;

  Future<bool?> _deleteAccount() async {
    final userProvider = context.read<UserProvider>();
    final authProvider = context.read<AuthProvider>();
    final logger = context.read<LoggerProvider>().logger;
    final storageProvider = context.read<FireStorageProvider>();
    final lastProviderId = authProvider.getLastLoggedInAuthProvider();

    setState(() {
      _deleting = true;
    });

    final applicantId = await _kycApi.fetchApplicantId();

    if (applicantId != null) {
      await _kycApi.deactivateApplicant(applicantId);

      logger.d(
        "KYC applicant is deactivated",
        time: DateTime.now(),
      );
    } else {
      logger.d(
        "Unable to deactivate KYC applicant due to NULL applicantId",
        time: DateTime.now(),
      );
    }

    /// Send email link to re-authenticate to avoid
    /// Firebase to throw "requires-recent-login"
    /// exception then postpone deletion until
    /// receiving email link
    if (lastProviderId == SocialAuthProvider.email) {
      await authProvider.sendSignInLinkToEmail(
        userProvider.getEmailCache(),
        reauthenticate: true,
      );

      return true;
    } else if (await authProvider.handleReAuthenticate(lastProviderId)) {
      await storageProvider.deleteImgStorage();
      await authProvider.deleteUser();

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }

    return false;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    _kycApi =
        IdentityVerification(uid: context.read<UserProvider>().getIdCache());
    super.didChangeDependencies();
  }

  /// Re-authenticate via email link
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final logger = context.read<LoggerProvider>().logger;
    final authProvider = context.read<AuthProvider>();
    final storageProvider = context.read<FireStorageProvider>();

    try {
      final subscription = FirebaseDynamicLinks.instance.onLink.listen(
        (event) async {
          if (await authProvider.handleReAuthenticate(event.link.toString())) {
            await storageProvider.deleteImgStorage();
            await authProvider.deleteUser();

            // ignore: use_build_context_synchronously
            Navigator.pop(context);
          }
        },
      );

      if (authProvider.isUninitialized()) {
        subscription.cancel();
      }
    } catch (e) {
      logger.e(e, time: DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.errorContainer,
      body: Dialog.fullscreen(
        child: SingleChildScrollView(
          child: Container(
            color: theme.colorScheme.errorContainer,
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 100,
              bottom: 20,
              left: 28,
              right: 28,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  size: 80,
                  Icons.dangerous_rounded,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 6),
                Text(
                  l10n!.pgProfileMenuItemDeleteAccount,
                  style: theme.textTheme
                      .apply(displayColor: theme.colorScheme.error)
                      .headlineMedium,
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.dialogDeleteAccountBody(l10n.brandName),
                  style: theme.textTheme
                      .apply(bodyColor: theme.colorScheme.error)
                      .bodyMedium,
                ),
                Container(
                  height: 60,
                  alignment: Alignment.center,
                  child: _deleting
                      ? LoadingAnimationWidget.threeArchedCircle(
                          size: 40,
                          color: theme.colorScheme.primary,
                        )
                      : null,
                ),
                TextField(
                  enabled: !_deleting,
                  decoration: InputDecoration(
                    labelText: l10n.dialogDeleteAccountLabel(
                      l10n.pgProfileMenuItemDeleteAccount,
                    ),
                  ),
                  onChanged: (value) {
                    if (value.trim() == l10n.pgProfileMenuItemDeleteAccount) {
                      setState(() {
                        _enabled = true;
                      });
                    } else {
                      setState(() {
                        _enabled = false;
                      });
                    }
                  },
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed:
                          _deleting ? null : () => Navigator.pop(context),
                      child: Text(l10n.cancel),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _enabled && !_deleting
                          ? () async {
                              if (await _deleteAccount() == true) {
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    duration: const Duration(seconds: 8),
                                    content: Text(
                                      l10n.dialogDeleteAccountReAuthEmailSent,
                                    ),
                                  ),
                                );
                              }
                            }
                          : null,
                      child: Text(l10n.delete),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
