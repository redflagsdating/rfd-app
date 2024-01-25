import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QodCalendarDay extends StatefulWidget {
  const QodCalendarDay({super.key, required this.day, this.style});

  final String day;
  final TextStyle? style;

  @override
  State<QodCalendarDay> createState() => _QodCalendarDayState();
}

class _QodCalendarDayState extends State<QodCalendarDay> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Align(
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Text(
            widget.day,
            style: widget.style,
            semanticsLabel: widget.day,
          ),
          Positioned(
            bottom: -10,
            child: Icon(
              Icons.check,
              size: 16,
              color: Colors.green,
              semanticLabel: l10n!.labelQodStatusAnswered(widget.day),
            ),
          ),
        ],
      ),
    );
  }
}
