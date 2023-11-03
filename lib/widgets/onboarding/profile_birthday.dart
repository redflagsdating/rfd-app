import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:red_flags/mixins/mixin_local_storage.dart';
import 'package:red_flags/mixins/mixin_onboard_state.dart';

class ProfileBirthday extends StatefulWidget {
  const ProfileBirthday({
    Key? key,
    this.enabled,
    required this.controller,
  }) : super(key: key);

  final bool? enabled;
  final TextEditingController controller;

  @override
  State<ProfileBirthday> createState() => _ProfileBirthdayState();
}

class _ProfileBirthdayState extends State<ProfileBirthday>
    with MixinOnboardState, MixinLocalStorage {
  String? _helperText;

  void _setHelperText(String value) {
    setState(() {
      _helperText = value;
    });
  }

  int _getAge(DateTime dob) {
    return (DateTime.now().difference(dob).inDays / 365).floor();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final currentYear = DateTime.now().year;
    final firstYear = DateTime(currentYear - 80);
    final lastYear = DateTime(currentYear - 18);
    final initialValue = widget.controller.text.isNotEmpty
        ? DateFormat.yMd().parse(widget.controller.text)
        : null;
    final initialDate =
        initialValue ?? lastYear.subtract(const Duration(days: 1));

    if (initialValue != null) {
      _setHelperText(l10n!.fieldBirthdayHelperText(_getAge(initialValue)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n!.pgOnboardBirthdayHeadline,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Text(l10n.pgOnboardBirthdayBody),
        const SizedBox(height: 48),
        FormBuilderDateTimePicker(
          name: "birthday",
          firstDate: firstYear,
          lastDate: lastYear,
          initialValue: initialValue,
          initialDate: initialDate,
          inputType: InputType.date,
          controller: widget.controller,
          enabled: widget.enabled != false,
          onChanged: (value) {
            if (value != null) {
              _setHelperText(l10n.fieldBirthdayHelperText(_getAge(value)));
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
        )
      ],
    );
  }
}
