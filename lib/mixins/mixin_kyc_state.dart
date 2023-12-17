import 'package:flutter/material.dart';
import 'package:flutter_idensic_mobile_sdk_plugin/flutter_idensic_mobile_sdk_plugin.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/identity_verification.dart';
import 'package:red_flags/services/user_provider.dart';

mixin MixinKycState<T extends StatefulWidget> on State<T> {
  void updateKycStatus() async {
    final userProvider = context.read<UserProvider>();
    final isVerified = userProvider.getVerifiedCache();
    final isVerifySubmitted = userProvider.getVerifySubmittedCache();

    // Do nothing if KYC is verified or not submitted yet
    if (isVerifySubmitted != true || isVerified == true) {
      return;
    }

    final uid = userProvider.getIdCache();
    final api = IdentityVerification(uid: uid);
    final applicantId = await api.fetchApplicantId();

    if (applicantId != null) {
      final status = await api.fetchReviewStatus(applicantId);

      if (status == SNSMobileSDKStatus.Approved) {
        userProvider.setVerified(true, silent: false, localOnly: false);
      } else if (status == SNSMobileSDKStatus.FinallyRejected) {
        userProvider.setVerified(false, silent: false, localOnly: false);
      }
    }
  }
}
