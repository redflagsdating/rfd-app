import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:red_flags/mixins/mixin_local_storage.dart';
import 'package:red_flags/models/user.dart';

/// ProfileGender is reused for gender and genderFor fields during onboarding
class ProfileGender extends StatefulWidget {
  const ProfileGender({
    Key? key,
    this.enabled,
    this.genderFor,
  }) : super(key: key);

  final bool? enabled;
  final bool? genderFor;

  @override
  State<ProfileGender> createState() => _OnboardProfileGenderState();
}

class _OnboardProfileGenderState extends State<ProfileGender>
    with MixinLocalStorage {
  String _gender = "";
  List<String> _genderFor = [];

  void _setGender(Gender? gender) {
    setState(() {
      if (gender != null) {
        // genderFor List<String>
        if (widget.genderFor == true) {
          if (_genderFor.contains(gender.name)) {
            _genderFor.remove(gender.name);
          } else {
            _genderFor.add(gender.name);
          }
          setGenderFor(_genderFor);
        }
        // gender String
        else {
          _gender = gender.name;
          setGender(_gender);
        }
      } else {
        _gender = "";
        removeGender();
      }
    });
  }

  @override
  void didChangeDependencies() {
    _gender = getGender() ?? "";
    _genderFor = getGenderFor() ?? [];

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isGenderForPage = widget.genderFor == true;
    final genderChips = [
      {
        "selected": _gender == Gender.man.name,
        "icon": Icons.man_2_rounded,
        "text": Text(l10n!.man(1).toUpperCase()),
        "key": Gender.man
      },
      {
        "selected": _gender == Gender.woman.name,
        "icon": Icons.woman_2_rounded,
        "text": Text(l10n.woman(1).toUpperCase()),
        "key": Gender.woman
      },
      {
        "selected": _gender == Gender.nonBinary.name,
        "icon": Icons.people,
        "text": Text(l10n.nonBinary.toUpperCase()),
        "key": Gender.nonBinary
      },
    ];
    final genderForChips = [
      {
        "selected": _genderFor.contains(Gender.man.name),
        "icon": Icons.man_2_rounded,
        "text": Text(l10n.man(1).toUpperCase()),
        "key": Gender.man
      },
      {
        "selected": _genderFor.contains(Gender.woman.name),
        "icon": Icons.woman_2_rounded,
        "text": Text(l10n.woman(1).toUpperCase()),
        "key": Gender.woman
      },
      {
        "selected": _genderFor.contains(Gender.nonBinary.name),
        "icon": Icons.people,
        "text": Text(l10n.nonBinary.toUpperCase()),
        "key": Gender.nonBinary
      },
    ];
    final chips = isGenderForPage ? genderForChips : genderChips;
    final title = isGenderForPage
        ? l10n.pgOnboardGenderForHeadline
        : l10n.pgOnboardGenderHeadline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall,
        ),
        isGenderForPage
            ? Column(
                children: [
                  const SizedBox(height: 10),
                  Text(l10n.pgOnboardGenderForBody),
                  const SizedBox(height: 48)
                ],
              )
            : const SizedBox(height: 48),
        for (var chip in chips)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: ChoiceChip(
              key: Key((chip["key"] as Gender).name),
              selected: chip["selected"] as bool,
              showCheckmark: false,
              avatar: Icon(
                chip["icon"] as IconData,
                size: 28,
              ),
              label: Container(
                height: 40,
                width: double.infinity,
                alignment: Alignment.centerLeft,
                child: chip["text"] as Widget,
              ),
              onSelected: widget.enabled == true
                  ? (value) {
                      _setGender(isGenderForPage || value
                          ? chip["key"] as Gender
                          : null);
                    }
                  : null,
            ),
          ),
      ],
    );
  }
}
