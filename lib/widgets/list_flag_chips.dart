import 'package:flutter/material.dart';

class ListFlagChips extends StatefulWidget {
  const ListFlagChips({
    Key? key,
    required this.labels,
    this.spacing,
    this.runSpacing,
    this.alignment,
    this.initialSelected,
    this.onSelected,
  }) : super(key: key);

  final List<String> labels;
  final double? spacing;
  final double? runSpacing;
  final WrapAlignment? alignment;
  final List<String>? initialSelected;
  final void Function(List<String> selected)? onSelected;

  @override
  State<ListFlagChips> createState() => _ListFlagChipsState();
}

class _ListFlagChipsState extends State<ListFlagChips> {
  final List<String> _selected = [];

  @override
  void initState() {
    final initialSelected = widget.initialSelected;

    if (initialSelected != null) {
      setState(() {
        _selected.addAll(initialSelected);
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Sort the labels to best use the space for chips
    final sorted = widget.labels.toList()
      ..sort((a, b) => a.length.compareTo(b.length));

    return Wrap(
      spacing: widget.spacing ?? 6,
      runSpacing: widget.runSpacing ?? 0,
      alignment: widget.alignment ?? WrapAlignment.start,
      children: List.generate(
        sorted.length,
        (index) {
          return ChoiceChip(
            label: Text(sorted[index]),
            selected: _selected.contains(sorted[index]),
            onSelected: (isSelected) {
              setState(() {
                if (isSelected && _selected.length < 3) {
                  _selected.add(sorted[index]);
                } else {
                  _selected.remove(sorted[index]);
                }

                widget.onSelected!(_selected);
              });
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }
}
