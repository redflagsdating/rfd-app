import 'dart:io';

import 'package:flutter/material.dart';
import 'package:red_flags/widgets/qod_calendar_day.dart';
import 'package:table_calendar/table_calendar.dart';

class QodCalendar extends StatefulWidget {
  const QodCalendar({
    super.key,
    required this.firstDay,
    required this.lastDay,
    this.onRangeSelected,
  });

  final DateTime firstDay;
  final DateTime lastDay;
  final void Function(
    DateTime? start,
    DateTime? end,
    DateTime focusedDay,
  )? onRangeSelected;

  @override
  State<QodCalendar> createState() => _QodCalendarState();
}

class _QodCalendarState extends State<QodCalendar> {
  DateTime? _rangeStartDay;
  DateTime? _rangeEndDay;
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _format = CalendarFormat.twoWeeks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outlineText = theme.textTheme.apply(
      bodyColor: theme.colorScheme.outline,
      displayColor: theme.colorScheme.outline,
    );

    return TableCalendar(
      locale: Platform.localeName,
      focusedDay: _focusedDay,
      firstDay: widget.firstDay,
      lastDay: widget.lastDay,
      calendarFormat: _format,
      rangeStartDay: _rangeStartDay,
      rangeEndDay: _rangeEndDay,
      rangeSelectionMode: RangeSelectionMode.toggledOn,
      onRangeSelected: (start, end, focusedDay) {
        setState(() {
          _rangeStartDay = start;
          _rangeEndDay = end;
          _focusedDay = focusedDay;
        });

        if (widget.onRangeSelected != null) {
          widget.onRangeSelected!(start, end, focusedDay);
        }
      },
      onFormatChanged: (format) {
        setState(() {
          _format = format;
        });
      },
      headerStyle: HeaderStyle(
        titleTextStyle: outlineText.titleMedium!,
        formatButtonVisible: false,
        titleCentered: true,
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: outlineText.labelLarge!,
        weekendStyle: outlineText.labelLarge!,
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          return QodCalendarDay(
            day: day.day.toString(),
            style: outlineText.bodySmall,
          );
        },
        outsideBuilder: (context, day, focusedDay) {
          return QodCalendarDay(
            day: day.day.toString(),
            style: outlineText.bodySmall,
          );
        },
        withinRangeBuilder: (context, day, focusedDay) {
          return QodCalendarDay(
            day: day.day.toString(),
            style: outlineText.bodySmall,
          );
        },
      ),
      calendarStyle: CalendarStyle(
        defaultTextStyle: outlineText.bodySmall!,
        outsideTextStyle: outlineText.bodySmall!,
        weekendTextStyle: outlineText.bodySmall!,
        rangeStartTextStyle: outlineText.bodySmall!,
        rangeEndTextStyle: outlineText.bodySmall!,
        withinRangeTextStyle: outlineText.bodySmall!,
        selectedTextStyle: outlineText.bodySmall!,
        todayTextStyle: theme.textTheme
            .apply(bodyColor: theme.colorScheme.onPrimaryContainer)
            .labelLarge!,
        disabledTextStyle: theme.textTheme
            .apply(displayColor: theme.colorScheme.outlineVariant)
            .bodySmall!,
        rangeHighlightColor:
            theme.colorScheme.secondaryContainer.withOpacity(0.4),
        rangeStartDecoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          shape: BoxShape.circle,
        ),
        rangeEndDecoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
