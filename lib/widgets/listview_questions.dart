import 'package:flutter/material.dart';

class ListViewQuestions extends StatelessWidget {
  const ListViewQuestions({
    super.key,
    required this.questions,
    this.selected,
    this.onSelect,
  });

  final List<String> questions;
  final List<String>? selected;
  final void Function(String question)? onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final question = questions[index];
        final isSelected = selected?.contains(question) ?? false;

        return Semantics(
          button: true,
          selected: isSelected,
          label: question,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 80),
            child: Card(
              elevation: isSelected ? 2 : 0,
              color: isSelected ? theme.colorScheme.inversePrimary : null,
              shape: isSelected
                  ? null
                  : RoundedRectangleBorder(
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
              child: InkWell(
                key: const Key("listview_questions_item_card"),
                onTap: isSelected
                    ? null
                    : () {
                        if (selected == null || !selected!.contains(question)) {
                          onSelect!(question);
                        }
                      },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      question,
                      style: theme.textTheme
                          .apply(bodyColor: theme.colorScheme.onSurface)
                          .titleMedium,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
