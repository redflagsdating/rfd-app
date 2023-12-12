import 'package:flutter/material.dart';

class ProfileSettingsMenuItem extends StatefulWidget {
  const ProfileSettingsMenuItem({
    Key? key,
    this.leadingIcon,
    this.leadingIconColor,
    this.trailingIcon,
    this.trailingIconColor,
    required this.label,
    this.labelColor,
    this.page,
    this.onTap,
  }) : super(key: key);

  final IconData? leadingIcon;
  final Color? leadingIconColor;
  final IconData? trailingIcon;
  final Color? trailingIconColor;
  final String label;
  final Color? labelColor;
  final Widget? page;
  final void Function()? onTap;

  @override
  State<ProfileSettingsMenuItem> createState() =>
      _ProfileSettingsMenuItemState();
}

class _ProfileSettingsMenuItemState extends State<ProfileSettingsMenuItem> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onTap = widget.onTap;

    return Material(
      child: InkWell(
        onTap: onTap ??
            () {
              final page = widget.page;

              if (page != null) {
                // Delay for UX transition
                Future.delayed(const Duration(milliseconds: 150), () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => page,
                    ),
                  );
                });
              }
            },
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.leadingIcon != null)
                Icon(
                  widget.leadingIcon,
                  size: 28,
                  color: widget.leadingIconColor ??
                      theme.colorScheme.onSurfaceVariant,
                ),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: theme.textTheme
                    .apply(
                        bodyColor: widget.labelColor ??
                            theme.colorScheme.onSurfaceVariant)
                    .labelLarge,
              ),
              const Spacer(),
              if (widget.trailingIcon != null)
                Icon(
                  widget.trailingIcon,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                )
            ],
          ),
        ),
      ),
    );
  }
}
