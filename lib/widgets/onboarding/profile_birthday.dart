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
    required this.birthdayCtrl,
  }) : super(key: key);

  final bool? enabled;
  final TextEditingController birthdayCtrl;

  @override
  State<ProfileBirthday> createState() => _ProfileBirthdayState();
}

class _ProfileBirthdayState extends State<ProfileBirthday>
    with MixinOnboardState, MixinLocalStorage {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final currentYear = DateTime.now().year;
    final firstYear = DateTime(currentYear - 80);
    final lastYear = DateTime(currentYear - 18);
    final initialValue = widget.birthdayCtrl.text.isNotEmpty
        ? DateFormat.yMd().parse(widget.birthdayCtrl.text)
        : null;
    final initialDate =
        initialValue ?? lastYear.subtract(const Duration(days: 1));

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
          controller: widget.birthdayCtrl,
          enabled: widget.enabled != false,
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            labelText: l10n.fieldBirthdayLabel,
          ),
        )
      ],
    );
  }
}
