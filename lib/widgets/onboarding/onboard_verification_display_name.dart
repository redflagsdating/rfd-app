import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Onboarding stage 1 Account verification > Step 2 Preferred Name
class OnboardVerificationDisplayName extends StatefulWidget {
  final bool? enabled;
  final TextEditingController displayNameCtrl;

  const OnboardVerificationDisplayName({
    super.key,
    this.enabled,
    required this.displayNameCtrl,
  });

  @override
  State<OnboardVerificationDisplayName> createState() =>
      _OnboardVerificationDisplayNameState();
}

class _OnboardVerificationDisplayNameState
    extends State<OnboardVerificationDisplayName> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      // A workaround of visual shifting issue from SingleChildScrollView +
      // PageSlideTransitionSwitcher.
      constraints: const BoxConstraints(
        minHeight: 400,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n!.pgOnboardDisplayNameHeadline,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(l10n.pgOnboardDisplayNameBody),
          const SizedBox(height: 48),
          TextFormField(
            maxLength: 50,
            autofocus: true,
            enabled: widget.enabled != false,
            controller: widget.displayNameCtrl,
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              labelText: l10n.pgOnboardDisplayNameLabel,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.pgOnboardDisplayNameErrorText;
              }

              return null;
            },
          ),
        ],
      ),
    );
  }
}
