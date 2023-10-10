import 'package:flutter/material.dart';
import 'package:red_flags/services/auth_provider.dart';

enum SnackBarType { error, warning, info, success }

/// `SnackBar` **mixin** provides *error, warning, info and success* levels of
/// styled SnackBar. It should only be used with ***page*** `Widget` thats
/// return `Scaffold` widget in `build` function.
mixin MixinSnackBar {
  void _showSnackBar(BuildContext context, String message, SnackBarType type) {
    late Color? color;
    late Color? backgroundColor;
    var duration = const Duration(seconds: 3);

    // TODO
    switch (type) {
      case SnackBarType.error:
        color = null;
        backgroundColor = null;
        duration = const Duration(seconds: 8);
        break;

      default:
        color = null;
        backgroundColor = null;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        closeIconColor: color,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        content: Text(
          message,
          style: TextStyle(color: color),
        ),
      ),
    );
  }

  ///** Info SnackBar */
  void showInfoSnackBar(BuildContext context, String message) {
    _showSnackBar(context, message, SnackBarType.info);
  }

  ///** Warning SnackBar */
  void showWarningSnackBar(BuildContext context, String message) {
    _showSnackBar(context, message, SnackBarType.warning);
  }

  ///** Error SnackBar */
  void showErrorSnackBar(BuildContext context, String message) {
    _showSnackBar(context, message, SnackBarType.error);
  }

  ///** Success SnackBar */
  void showSuccessSnackBar(BuildContext context, String message) {
    _showSnackBar(context, message, SnackBarType.success);
  }

  ///** AuthStatus SnackBar */
  void showAuthStatusSnackBar(BuildContext context, AuthProvider authProvider) {
    switch (authProvider.status) {
      case AuthStatus.authenticateCanceled:
        showWarningSnackBar(context, authProvider.message);
        break;

      case AuthStatus.authenticateError:
        showErrorSnackBar(context, authProvider.message);
        break;

      default:
        break;
    }
  }
}
