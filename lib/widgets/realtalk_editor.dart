import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RealTalkEditor extends StatefulWidget {
  const RealTalkEditor({
    super.key,
    this.enabled,
    this.onBack,
    this.onDelete,
    this.onEditingComplete,
    required this.question,
    required this.controller,
  });

  final bool? enabled;
  final void Function()? onBack;
  final void Function()? onDelete;
  final void Function()? onEditingComplete;
  final String question;
  final TextEditingController controller;

  @override
  State<RealTalkEditor> createState() => _RealTalkEditorState();
}

class _RealTalkEditorState extends State<RealTalkEditor> {
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
                    ? Semantics(
                        button: true,
                        enabled: true,
                        label: l10n!.back,
                        child: IconButton(
                          key: const Key("realtalk_editor_back_button"),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          onPressed: isEnabled ? widget.onBack : null,
                        ),
                      )
                    : widget.onDelete != null
                        ? Semantics(
                            button: true,
                            enabled: true,
                            label: l10n!.delete,
                            child: IconButton(
                              key: const Key("realtalk_editor_delete_button"),
                              icon: const Icon(Icons.delete),
                              onPressed: isEnabled ? widget.onDelete : null,
                            ),
                          )
                        : const SizedBox.shrink(),
              ),
              Expanded(
                child: Text(
                  l10n!.realtalkEditorTitle,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: 80,
                alignment: Alignment.centerRight,
                child: Semantics(
                  button: true,
                  enabled: isEnabled,
                  label: l10n.done,
                  child: TextButton(
                    key: const Key("realtalk_editor_save_button"),
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
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            key: const Key("realtalk_editor_display_title"),
            widget.question,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          Semantics(
            textField: true,
            enabled: isEnabled,
            label: l10n.realtalkEditorHintText,
            child: TextFormField(
              autofocus: true,
              minLines: 4,
              maxLines: 4,
              maxLength: 250,
              enabled: isEnabled,
              controller: widget.controller,
              key: const Key("realtalk_editor_textfield"),
              textCapitalization: TextCapitalization.sentences,
              buildCounter: (context,
                  {required currentLength, required isFocused, maxLength}) {
                return Container(
                  transform: Matrix4.translationValues(0, -175, 0),
                  child: Text(
                    "$currentLength/$maxLength",
                    style: theme.textTheme
                        .apply(bodyColor: theme.colorScheme.outline)
                        .labelMedium,
                  ),
                );
              },
              decoration: InputDecoration(
                errorMaxLines: 2,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  ),
                ),
                hintText: l10n.realtalkEditorHintText,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.realtalkEditorEmptyErrorText;
                }

                if (value.length < 100) {
                  return l10n.realtalkEditorShortErrorText;
                }

                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
