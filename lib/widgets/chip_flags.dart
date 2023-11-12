import 'package:flutter/material.dart';

class ChipFlags extends StatefulWidget {
  const ChipFlags({
    Key? key,
    required this.flags,
    this.initialSelected,
    this.onSelected,
  }) : super(key: key);

  final List<String> flags;
  final List<String>? initialSelected;
  final void Function(List<String> selected)? onSelected;

  @override
  State<ChipFlags> createState() => _ChipFlagsState();
}

class _ChipFlagsState extends State<ChipFlags> {
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
    final sorted = widget.flags.toList()
      ..sort((a, b) => a.length.compareTo(b.length));

    return Wrap(
      spacing: 6,
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
