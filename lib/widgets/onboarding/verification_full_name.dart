import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Onboarding stage 1 Account verification > Step 1 Full Name
class VerificationFullName extends StatefulWidget {
  final bool? enabled;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;

  const VerificationFullName({
    super.key,
    this.enabled,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
  });

  @override
  State<VerificationFullName> createState() => _VerificationFullNameState();
}

class _VerificationFullNameState extends State<VerificationFullName> {
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
            autofocus: true,
            enabled: isEnabled,
            controller: widget.firstNameCtrl,
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              hintText: l10n.fieldFirstNameHintText,
              helperText: l10n.fieldFirstNameHelperText,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.fieldFirstNameErrorText;
              }

              return null;
            },
          ),
          const SizedBox(height: 24),
          TextFormField(
            enabled: isEnabled,
            controller: widget.lastNameCtrl,
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              hintText: l10n.fieldLastNameHintText,
              helperText: l10n.fieldLastNameHelperText,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.fieldLastNameErrorText;
              }

              return null;
            },
          ),
        ],
      ),
    );
  }
}
