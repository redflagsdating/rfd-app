import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QuestionEditor extends StatefulWidget {
  const QuestionEditor({
    Key? key,
    this.enabled,
    this.onBack,
    this.onEditingComplete,
    required this.question,
    required this.controller,
  }) : super(key: key);

  final bool? enabled;
  final void Function()? onBack;
  final void Function()? onEditingComplete;
  final String question;
  final TextEditingController controller;

  @override
  State<QuestionEditor> createState() => _QuestionEditorState();
}

class _QuestionEditorState extends State<QuestionEditor> {
  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isEnabled = widget.enabled != false;

    return Form(
      key: _form,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80,
                alignment: Alignment.centerLeft,
                child: widget.onBack != null
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: isEnabled ? widget.onBack : null,
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: Text(
                  l10n!.questionEditorTitle,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: 80,
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: isEnabled
                      ? () {
                          if (!_form.currentState!.validate()) {
                            return;
                          }

                          widget.onEditingComplete!();
                        }
                      : null,
                  child: Text(l10n.done),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            widget.question,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          TextFormField(
            autofocus: true,
            minLines: 4,
            maxLines: 4,
            maxLength: 250,
            enabled: isEnabled,
            controller: widget.controller,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              errorMaxLines: 2,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(12),
                ),
              ),
              hintText: l10n.questionEditorHintText,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.questionEditorEmptyErrorText;
              }

              // TODO: Revisit later, meaningful sentence roughly 10-30 words
              if (value.length < 100) {
                return l10n.questionEditorShortErrorText;
              }

              return null;
            },
          ),
        ],
      ),
    );
  }
}
