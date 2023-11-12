import 'package:flutter/material.dart';
import 'package:red_flags/models/question.dart';

class ListViewQuestions extends StatelessWidget {
  const ListViewQuestions({
    Key? key,
    required this.questions,
    this.selected,
    this.onSelect,
  }) : super(key: key);

  final List<String> questions;
  final List<String>? selected;
  final void Function(String question)? onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      itemCount: QuestionModel.questions.length,
      itemBuilder: (context, index) {
        final question = QuestionModel.questions[index];
        final isSelected = selected?.contains(question) ?? false;

        return GestureDetector(
          onTap: () {
            if (!selected!.contains(question)) {
              onSelect!(question);
            }
          },
          child: Card(
            elevation: isSelected ? 2 : 0,
            shape: isSelected
                ? null
                : RoundedRectangleBorder(
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                question,
                style: theme.textTheme
                    .apply(
                      bodyColor: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurfaceVariant,
                    )
                    .titleMedium,
              ),
            ),
          ),
        );
      },
    );
  }
}
