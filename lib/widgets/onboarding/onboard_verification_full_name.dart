import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Onboarding stage 1 Account verification > Step 1 Full Name
class OnboardVerificationFullName extends StatefulWidget {
  final bool? enabled;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;

  const OnboardVerificationFullName({
    super.key,
    this.enabled,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
  });

  @override
  State<OnboardVerificationFullName> createState() =>
      _OnboardVerificationFullNameState();
}

class _OnboardVerificationFullNameState
    extends State<OnboardVerificationFullName> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isEnabled = widget.enabled != false;

    return Container(
      // A workaround of visual shifting issue from SingleChildScrollView +
      // PageSlideTransitionSwitcher.
      constraints: const BoxConstraints(
        minHeight: 400,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n!.pgOnboardFullNameHeadline,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(l10n.pgOnboardFullNameBody),
          const SizedBox(height: 48),
          TextFormField(
            maxLength: 50,
            autofocus: true,
            enabled: isEnabled,
            controller: widget.firstNameCtrl,
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              labelText: l10n.pgOnboardFirstNameLabel,
              helperText: l10n.pgOnboardFirstNameHelperText,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.pgOnboardFirstNameErrorText;
              }

              return null;
            },
          ),
          const SizedBox(height: 24),
          TextFormField(
            maxLength: 50,
            enabled: isEnabled,
            controller: widget.lastNameCtrl,
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              labelText: l10n.pgOnboardLastNameLabel,
              helperText: l10n.pgOnboardLastNameHelperText,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.pgOnboardLastNameErrorText;
              }

              return null;
            },
          ),
        ],
      ),
    );
  }
}
