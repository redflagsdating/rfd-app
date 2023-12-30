import 'package:flutter/material.dart';

class ListFlagChoiceChips extends StatefulWidget {
  const ListFlagChoiceChips({
    super.key,
    required this.labels,
    this.enabled,
    this.spacing,
    this.runSpacing,
    this.alignment,
    this.selected,
    this.onAdded,
    this.onDeleted,
  });

  final bool? enabled;
  final List<String> labels;
  final double? spacing;
  final double? runSpacing;
  final WrapAlignment? alignment;
  final List<String>? selected;
  final void Function(String value)? onAdded;
  final void Function(String value)? onDeleted;

  @override
  State<ListFlagChoiceChips> createState() => _ListFlagChoiceChipsState();
}

class _ListFlagChoiceChipsState extends State<ListFlagChoiceChips> {
  @override
  Widget build(BuildContext context) {
    // Sort the labels to best use the space for chips
    final sorted = widget.labels.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return Wrap(
      spacing: widget.spacing ?? 6,
      runSpacing: widget.runSpacing ?? 0,
      alignment: widget.alignment ?? WrapAlignment.start,
      children: List.generate(
        sorted.length,
        (index) {
          final selected = (widget.selected ?? []);
          final isSelected = selected.contains(sorted[index]);
          final isEnabled = isSelected || (widget.enabled ?? true);

          return Semantics(
            selected: isSelected,
            button: true,
            label: sorted[index],
            child: ChoiceChip(
              showCheckmark: false,
              visualDensity: VisualDensity.compact,
              label: Text(sorted[index]),
              selected: isSelected,
              onSelected: isEnabled
                  ? (selectedState) {
                      setState(() {
                        if (selectedState && selected.length < 3) {
                          widget.onAdded!(sorted[index]);
                        } else {
                          widget.onDeleted!(sorted[index]);
                        }
                      });
                    }
                  : null,
            ),
          );
        },
      ),
    );
  }
}
