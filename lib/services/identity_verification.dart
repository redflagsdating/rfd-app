import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_idensic_mobile_sdk_plugin/flutter_idensic_mobile_sdk_plugin.dart';
import 'package:http/http.dart' as http;

class IdentityVerification {
  final _token = dotenv.get("SUMSUB_APP_TOKEN");
  final _secrets = dotenv.get("SUMSUB_SECRETS");
  final _apiHost = FlavorConfig.instance.variables["sumsubApiHost"];
  final Map<String, String> _defaultParams = {"levelName": "basic-kyc-level"};

  IdentityVerification({required this.uid}) {
    _defaultParams["userId"] = uid;
  }

  final String uid;

  //
  static bool isUploaded(SNSMobileSDKStatus? status) {
    return status != null &&
        [
          SNSMobileSDKStatus.Pending,
          SNSMobileSDKStatus.TemporarilyDeclined,
          SNSMobileSDKStatus.FinallyRejected,
          SNSMobileSDKStatus.Approved,
          SNSMobileSDKStatus.ActionCompleted,
        ].contains(status);
  }

  //
  Uri _getUri(String path, [Map<String, String>? queryParameters]) {
    return Uri.https(
      _apiHost,
      '/resources$path',
      {..._defaultParams, ...(queryParameters ?? {})},
    );
  }

  //
  Map<String, String> _getHeaders(String method, Uri uri) {
    /// See more details about required headers and specs
    /// https://docs.sumsub.com/reference/authentication#sign-requests
    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    final signedString = '$timestamp$method${uri.path}?${uri.query}';
    final hmac = Hmac(sha256, utf8.encode(_secrets));
    final signature = hmac.convert(utf8.encode(signedString));

    /// See required request headers
    /// https://docs.sumsub.com/reference/authentication#make-requests
    return {
      "X-App-Token": _token,
      "X-App-Access-Sig": signature.toString(),
      "X-App-Access-Ts": timestamp.toString(),
    };
  }

  //
  Future<String?> fetchAccessToken() async {
    final uri = _getUri('/accessTokens');
    final response = await http.post(uri, headers: _getHeaders('POST', uri));
    final data = json.decode(response.body);

    return data?['token'];
  }

  //
  Future<String?> fetchApplicantId() async {
    final uri = _getUri('/applicants/-;externalUserId=$uid/one');
    final response = await http.get(uri, headers: _getHeaders('GET', uri));
    final data = json.decode(response.body);

    return data?["id"];
  }

  Future<bool?> deactivateApplicant(String applicantId) async {
    final uri = _getUri('/applicants/$applicantId/presence/deactivated');
    final response = await http.patch(uri, headers: _getHeaders('PATCH', uri));
    final data = json.decode(response.body);

    return data["deleted"];
  }

  //
  Future<SNSMobileSDKStatus?> fetchReviewStatus(String applicantId) async {
    final uri = _getUri('/applicants/$applicantId/status');
    final response = await http.get(uri, headers: _getHeaders('GET', uri));
    final data = json.decode(response.body);
    final status = data?['reviewStatus'];
    final result = data?['reviewResult'];

    if (status == 'init') {
      return SNSMobileSDKStatus.Initial;
    }

    // TODO: Revisit to justify status mapping
    if (status != null &&
        ['pending', 'prechecked', 'queued', 'onHold'].contains(status)) {
      return SNSMobileSDKStatus.Pending;
    }

    if (status == 'completed') {
      if (result?['reviewAnswer'] == 'GREEN') {
        return SNSMobileSDKStatus.Approved;
      } else if (result?['reviewAnswer'] == 'RED') {
        return SNSMobileSDKStatus.FinallyRejected;
      }
    }

    return null;
  }
}
