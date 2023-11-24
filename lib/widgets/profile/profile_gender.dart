import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/services/user_provider.dart';

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

class _OnboardProfileGenderState extends State<ProfileGender> {
  String _gender = "";
  List<String> _genderFor = [];
  late UserProvider _userProvider;

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
          _userProvider.setGenderFor(_genderFor);
        }
        // gender String
        else {
          _gender = gender.name;
          _userProvider.setGender(_gender);
        }
      } else {
        _gender = "";
        _userProvider.setGender("");
      }
    });
  }

  @override
  void didChangeDependencies() {
    _userProvider = Provider.of<UserProvider>(context);

    _gender = _userProvider.getGenderCache() ?? "";
    _genderFor = _userProvider.getGenderForCache() ?? [];

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isGenderForPage = widget.genderFor == true;
    final genderChips = [
      {
        "selected": _gender == Gender.woman.name,
        "icon": FontAwesomeIcons.venus,
        "text": Text(l10n!.woman(1).toUpperCase()),
        "key": Gender.woman
      },
      {
        "selected": _gender == Gender.man.name,
        "icon": FontAwesomeIcons.mars,
        "text": Text(l10n.man(1).toUpperCase()),
        "key": Gender.man
      },
      {
        "selected": _gender == Gender.nonBinary.name,
        "icon": FontAwesomeIcons.marsAndVenus,
        "text": Text(l10n.nonBinary.toUpperCase()),
        "key": Gender.nonBinary
      },
    ];
    final genderForChips = [
      {
        "selected": _genderFor.contains(Gender.woman.name),
        "icon": FontAwesomeIcons.venus,
        "text": Text(l10n.woman(1).toUpperCase()),
        "key": Gender.woman
      },
      {
        "selected": _genderFor.contains(Gender.man.name),
        "icon": FontAwesomeIcons.mars,
        "text": Text(l10n.man(1).toUpperCase()),
        "key": Gender.man
      },
      {
        "selected": _genderFor.contains(Gender.nonBinary.name),
        "icon": FontAwesomeIcons.marsAndVenus,
        "text": Text(l10n.nonBinary.toUpperCase()),
        "key": Gender.nonBinary
      },
    ];
    final chips = isGenderForPage ? genderForChips : genderChips;
    final title =
        isGenderForPage ? l10n.pgGenderForHeadline : l10n.pgGenderHeadline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall,
        ),
        Column(
          children: [
            const SizedBox(height: 10),
            Text(isGenderForPage ? l10n.pgGenderForBody : l10n.pgGenderBody),
            const SizedBox(height: 48)
          ],
        ),
        for (var chip in chips)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: ChoiceChip(
              key: Key((chip["key"] as Gender).name),
              selected: chip["selected"] as bool,
              showCheckmark: false,
              avatar: FaIcon(
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
