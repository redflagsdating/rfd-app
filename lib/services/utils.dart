import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Utils {
  static final websiteUrl = FlavorConfig.instance.variables["websiteUrl"];

  static Future<bool> launchWebview(String url) async {
    return await launchUrlString(url, mode: LaunchMode.inAppBrowserView);
  }

  static Future<bool> launchFaqWebview() async {
    return await launchWebview('$websiteUrl/faqs');
  }

  static Future<bool> launchTncWebview() async {
    return await launchWebview('$websiteUrl/terms-and-conditions');
  }

  static Future<bool> launchPrivacyPolicyWebview() async {
    return await launchWebview('$websiteUrl/privacy-policy');
  }

  static Future<bool> launchCookiePolicyWebview() async {
    return await launchWebview('$websiteUrl/cookies-policy');
  }
}
