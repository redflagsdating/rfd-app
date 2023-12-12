import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_idensic_mobile_sdk_plugin/flutter_idensic_mobile_sdk_plugin.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/identity_verification.dart';
import 'package:red_flags/services/logger_provider.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/animation/fade_through_transition_switcher.dart';
import 'package:red_flags/widgets/label_kyc_status.dart';

class ProfileKyc extends StatefulWidget {
  const ProfileKyc({super.key, this.onboarding});

  final bool? onboarding;

  @override
  State<ProfileKyc> createState() => _ProfileKycState();
}

class _ProfileKycState extends State<ProfileKyc> {
  SNSMobileSDKStatus? _status;
  bool _verifying = false;
  late IdentityVerification _kycApi;

  void _updateUserStatus(SNSMobileSDKStatus status) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isVerifySubmitted = userProvider.getVerifySubmittedCache();
    final isVerified = userProvider.getVerifiedCache();

    if (isVerifySubmitted != true) {
      if (IdentityVerification.isUploaded(status)) {
        userProvider.setVerifySubmitted(true, localOnly: false, silent: false);
      }
    } else if (isVerified != true && status == SNSMobileSDKStatus.Approved) {
      userProvider.setVerified(true, localOnly: false, silent: false);
    }
  }

  Future<SNSMobileSDKResult> launchKYC() async {
    setState(() {
      _verifying = true;
    });

    final accessToken = await _kycApi.fetchAccessToken();
    final snsMobileSDK =
        SNSMobileSDK.init(accessToken, _kycApi.fetchAccessToken)
            // .withTheme({
            //   // TODO: Customise theme
            //   "universal": {
            //     "colors": {
            //       "primaryButtonBackground": "0xFFFF0049",
            //     },
            //   }
            // })
            .withHandlers(
              onStatusChanged: (status, prevStatus) {
                _updateUserStatus(status);
              },
            )
            .withDebug(kDebugMode)
            .build();
    final SNSMobileSDKResult result = await snsMobileSDK.launch();

    setState(() {
      _verifying = false;
      _status = result.status;
    });

    return result;
  }

  @override
  void didChangeDependencies() {
    final uid = context.read<UserProvider>().getIdCache();
    _kycApi = IdentityVerification(uid: uid);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final logger = Provider.of<LoggerProvider>(context).logger;

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipOval(
          child: Container(
            padding: const EdgeInsets.all(36),
            color: theme.colorScheme.inversePrimary,
            child: Icon(
              FontAwesomeIcons.addressCard,
              color: theme.colorScheme.onPrimary,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          l10n!.pgKycHeadline,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Text(l10n.pgKycBody),
        const SizedBox(height: 80),
        Container(
          alignment: Alignment.center,
          child: FadeThroughTransitionSwitcher(
            child: IdentityVerification.isUploaded(_status)
                ? LabelKycStatus(status: _status)
                : FilledButton.icon(
                    icon: _verifying
                        ? Container(
                            width: 16,
                            height: 16,
                            margin: const EdgeInsets.symmetric(
                              vertical: 7,
                              horizontal: 4,
                            ),
                            child:
                                const CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(widget.onboarding == true
                            ? Icons.fact_check_outlined
                            : Icons.refresh),
                    onPressed: _verifying
                        ? null
                        : () {
                            launchKYC().then((result) {
                              var message = result.errorMsg;
                              bool showAction = false;

                              if (result.success) {
                                _updateUserStatus(result.status);

                                switch (result.status) {
                                  case SNSMobileSDKStatus.Ready:
                                  case SNSMobileSDKStatus.Initial:
                                  case SNSMobileSDKStatus.Incomplete:
                                    message = l10n.pgKycIncompleteMessage;
                                    break;

                                  case SNSMobileSDKStatus.Pending:
                                    message = l10n.pgKycPendingMessage;
                                    break;

                                  case SNSMobileSDKStatus.TemporarilyDeclined:
                                    showAction = true;
                                    message = l10n.pgKycDeclinedMessage;
                                    logger.d(
                                      result.toString(),
                                      time: DateTime.now(),
                                    );
                                    break;

                                  case SNSMobileSDKStatus.FinallyRejected:
                                    showAction = true;
                                    message = l10n.pgKycRejectedMessage;
                                    logger.d(
                                      result.toString(),
                                      time: DateTime.now(),
                                    );
                                    break;

                                  default:
                                    break;
                                }
                              } else {
                                logger.e('[${result.errorType}] $message',
                                    time: DateTime.now());
                              }

                              if (message != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(message),
                                    action: showAction
                                        ? SnackBarAction(
                                            label: l10n.contactUs,
                                            onPressed: () {
                                              // TODO: Open support channel
                                            },
                                          )
                                        : null,
                                  ),
                                );
                              }
                            });
                          },
                    label: Text(widget.onboarding == true
                        ? l10n.pgKycOnboardBtn
                        : l10n.pgKycBtn),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 320,
          child: Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              style: theme.textTheme.bodySmall,
              text: l10n.pgKycFooter(l10n.brandName),
              children: [
                const TextSpan(text: ' '),
                TextSpan(
                  text: l10n.privacyPolicy,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // TODO: Open privacy policy page
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
