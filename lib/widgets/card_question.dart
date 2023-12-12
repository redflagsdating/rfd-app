import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:red_flags/widgets/animation/fade_through_transition_switcher.dart';
import 'package:red_flags/widgets/animation/slide_transition_switcher.dart';
import 'package:red_flags/widgets/listview_questions.dart';
import 'package:red_flags/widgets/question_editor.dart';

class CardQuestion extends StatefulWidget {
  const CardQuestion({
    Key? key,
    required this.listQuestions,
    this.selectedQuestions,
    this.initialQuestion,
    this.initialAnswer,
    this.hintText,
    this.icon,
    this.onAdded,
    this.onDeleted,
  }) : super(key: key);

  final List<String> listQuestions;
  final List<String>? selectedQuestions;
  final String? initialQuestion;
  final String? initialAnswer;
  final String? hintText;
  final IconData? icon;
  final void Function(String question, String answer)? onAdded;
  final void Function(String question)? onDeleted;

  @override
  State<CardQuestion> createState() => _CardQuestionState();
}

class _CardQuestionState extends State<CardQuestion> {
  String? _question;
  final _controller = TextEditingController();

  // Do Not inline to ensure using this widget's context and setState
  void _onAdded() {
    widget.onAdded!(_question!, _controller.text);
    Navigator.of(context).pop();
    setState(() {});
  }

  void _onDeleted() {
    widget.onDeleted!(_question!);
    Navigator.pop(context);
    setState(() {
      _question = null;
      _controller.clear();
    });
  }

  @override
  void initState() {
    _question = widget.initialQuestion;
    _controller.text = widget.initialAnswer ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final placeholderColor = theme.colorScheme.inversePrimary;

    Future onConfirmDelete() {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: Icon(
              size: 50,
              Icons.warning_amber_rounded,
              color: theme.colorScheme.error,
            ),
            title: Text(
              l10n!.dialogDeleteRealTalkCardTitle,
            ),
            content: Text(
              l10n.dialogDeleteRealTalkCardBody,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: _onDeleted,
                child: Text(l10n.delete),
              )
            ],
          );
        },
      );
    }

    return GestureDetector(
      onTap: () {
        showModalBottomSheet<void>(
          elevation: 0,
          context: context,
          useSafeArea: true,
          showDragHandle: true,
          isScrollControlled: true,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  child: SlideTransitionSwitcher(
                    child: _question != null
                        ? QuestionEditor(
                            question: _question!,
                            controller: _controller,
                            onDelete: widget.initialQuestion != null
                                ? () {
                                    onConfirmDelete().whenComplete(
                                        () => Navigator.pop(context));
                                  }
                                : null,
                            onBack: widget.initialQuestion != null
                                ? null
                                : () {
                                    setState(() {
                                      _question = null;
                                      _controller.clear();
                                    });
                                  },
                            onEditingComplete: _onAdded,
                          )
                        : ListViewQuestions(
                            questions: widget.listQuestions,
                            selected: widget.selectedQuestions,
                            onSelect: (question) {
                              setState(() {
                                _question = question;
                                _controller.clear();
                              });
                            },
                          ),
                  ),
                );
              },
            );
          },
        ).whenComplete(() {
          // Reset state when bottom sheet is dismissed manually
          if (_controller.text.isEmpty) {
            _question = null;
            _controller.clear();
          }
        });
      },
      onLongPress: () {
        if (_question != null) {
          HapticFeedback.heavyImpact();
          onConfirmDelete();
        }
      },
      child: FadeThroughTransitionSwitcher(
        child: _question != null
            ? Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset.zero,
                      blurRadius: 4,
                      color: theme.colorScheme.surfaceVariant,
                    )
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _question!,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _controller.text,
                      maxLines: 3,
                      overflow: TextOverflow.fade,
                      style: theme.textTheme.bodySmall,
                    )
                  ],
                ),
              )
            : DottedBorder(
                dashPattern: const [10, 5],
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                color: theme.colorScheme.inversePrimary,
                child: SizedBox(
                  width: double.infinity,
                  height: 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        size: 32,
                        widget.icon ?? Icons.question_answer_outlined,
                        color: placeholderColor,
                      ),
                      if (widget.hintText != null)
                        Text(
                          widget.hintText!,
                          style: theme.textTheme
                              .apply(bodyColor: placeholderColor)
                              .labelLarge,
                        )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
