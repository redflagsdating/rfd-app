import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Onboarding stage 1 Account verification > Step 2 Preferred Name
class VerificationDisplayName extends StatefulWidget {
  final bool? enabled;
  final TextEditingController controller;

  const VerificationDisplayName({
    super.key,
    this.enabled,
    required this.controller,
  });

  @override
  State<VerificationDisplayName> createState() =>
      _VerificationDisplayNameState();
}

class _VerificationDisplayNameState extends State<VerificationDisplayName> {
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
            l10n!.pgDisplayNameHeadline,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(l10n.pgDisplayNameBody),
          const SizedBox(height: 48),
          TextFormField(
            autofocus: true,
            enabled: widget.enabled != false,
            controller: widget.controller,
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              hintText: l10n.fieldDisplayNameHintText,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.fieldDisplayNameErrorText;
              }

              return null;
            },
          ),
        ],
      ),
    );
  }
}
