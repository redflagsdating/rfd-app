import 'package:flutter/material.dart';

class ProfileSettingsMenu extends StatefulWidget {
  const ProfileSettingsMenu({
    Key? key,
    this.title,
    required this.children,
  }) : super(key: key);

  final String? title;
  final List<Widget> children;

  @override
  State<ProfileSettingsMenu> createState() => _ProfileSettingsMenuState();
}

class _ProfileSettingsMenuState extends State<ProfileSettingsMenu> {
  @override
  Widget build(BuildContext context) {
    final title = widget.title;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: theme.textTheme.titleMedium,
            ),
          ),
        Container(
          width: double.infinity,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: widget.children,
          ),
        ),
      ],
    );
  }
}
