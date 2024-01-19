import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/user_provider.dart';

class ProfileBirthday extends StatefulWidget {
  const ProfileBirthday({
    super.key,
    this.enabled,
    required this.controller,
  });

  final bool? enabled;
  final TextEditingController controller;

  @override
  State<ProfileBirthday> createState() => _ProfileBirthdayState();
}

class _ProfileBirthdayState extends State<ProfileBirthday> {
  String? _helperText;

  void _setHelperText(String value) {
    setState(() {
      _helperText = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final userProvider = context.read<UserProvider>();
    final currentYear = DateTime.now().year;
    final firstYear = DateTime(currentYear - 80);
    final lastYear = DateTime(currentYear - 18);
    final initialValue = widget.controller.text.isNotEmpty
        ? DateFormat.yMd(Platform.localeName).parse(widget.controller.text)
        : null;
    final initialDate =
        initialValue ?? lastYear.subtract(const Duration(days: 1));
    final locale = Platform.localeName.split("_");

    if (initialValue != null) {
      _setHelperText(
          l10n!.fieldBirthdayHelperText(userProvider.getAge(initialValue)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n!.pgBirthdayHeadline,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Text(l10n.pgBirthdayBody),
        const SizedBox(height: 48),
        Semantics(
          focusable: true,
          textField: true,
          label: l10n.fieldBirthdayHintText,
          child: FormBuilderDateTimePicker(
            name: "birthday",
            firstDate: firstYear,
            lastDate: lastYear,
            initialValue: initialValue,
            initialDate: initialDate,
            inputType: InputType.date,
            controller: widget.controller,
            // For its inline TextField in editor to display locale-sensitive
            // date format
            locale: Locale(locale.first, locale.last),
            // For its TextField to display DateTime value
            format: DateFormat.yMd(Platform.localeName),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            enabled: widget.enabled != false,
            validator: (value) {
              if (value == null) {
                return l10n.fieldBirthdayEmptyErrorText;
              }

              return null;
            },
            onChanged: (value) {
              if (value != null) {
                _setHelperText(
                    l10n.fieldBirthdayHelperText(userProvider.getAge(value)));
              } else {
                _setHelperText("");
              }
            },
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              hintText: l10n.fieldBirthdayHintText,
              helperText: _helperText,
              helperStyle: widget.controller.text.isNotEmpty
                  ? TextStyle(
                      color: theme.colorScheme.secondary,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
