import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:red_flags/models/qod.dart';
import 'package:red_flags/widgets/circle_avatar_user.dart';
import 'package:red_flags/widgets/label/label_qod_status.dart';

class CardQod extends StatefulWidget {
  const CardQod({super.key, required this.qod, this.onTap});
  final QodModel qod;
  final void Function()? onTap;

  @override
  State<CardQod> createState() => _CardQodState();
}

class _CardQodState extends State<CardQod> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Card(
          elevation: 2,
          child: InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Text(
                      widget.qod.question,
                      maxLines: 2,
                      semanticsLabel: widget.qod.question,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      LabelQodStatus(qod: widget.qod),
                      const Spacer(),
                      CircleAvatarUser(
                        photoUrl: widget.qod.primaryUserPhotoUrl,
                        size: 40,
                      ),
                      const SizedBox(width: 6),
                      CircleAvatarUser(
                        photoUrl: widget.qod.secondaryUserPhotoUrl,
                        size: 40,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 18,
          right: 20,
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        if (widget.qod.isNew)
          Positioned(
            top: -20,
            left: 20,
            child: Chip(
              padding: const EdgeInsets.all(0),
              label: Text(l10n!.labelNew),
              labelStyle: theme.textTheme
                  .apply(bodyColor: theme.colorScheme.onSecondary)
                  .labelSmall,
              visualDensity: VisualDensity.compact,
              side: MaterialStateBorderSide.resolveWith((states) {
                return const BorderSide(color: Colors.transparent);
              }),
              color: MaterialStateProperty.resolveWith(
                (states) {
                  return theme.colorScheme.secondary;
                },
              ),
            ),
          ),
      ],
    );
  }
}
