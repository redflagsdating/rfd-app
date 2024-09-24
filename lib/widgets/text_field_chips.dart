import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:red_flags/extensions/string_extension.dart';
import 'package:textfield_tags/textfield_tags.dart';

class TextFieldChips extends StatefulWidget {
  const TextFieldChips({
    super.key,
    this.readOnly,
    this.labelText,
    this.hintText,
    this.helperText,
    this.initialChips,
    this.validator,
    this.onDeleted,
  });

  final bool? readOnly;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final List<String>? initialChips;
  final String? Function(String)? validator;
  final void Function(String)? onDeleted;

  @override
  State<TextFieldChips> createState() => _TextFieldChipsState();
}

class _TextFieldChipsState extends State<TextFieldChips> {
  late StringTagController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StringTagController();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return TextFieldTags<String>(
      textfieldTagsController: _controller,
      initialTags: widget.initialChips,
      letterCase: LetterCase.normal,
      textSeparators: const [','],
      validator: widget.validator,
      inputFieldBuilder: (context, inputFieldValues) {
        return Semantics(
          textField: true,
          readOnly: widget.readOnly,
          label: widget.labelText,
          child: TextField(
            readOnly: widget.readOnly ?? false,
            controller: inputFieldValues.textEditingController,
            focusNode: inputFieldValues.focusNode,
            onChanged: inputFieldValues.onTagChanged,
            onSubmitted: inputFieldValues.onTagSubmitted,
            maxLength: 20,
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              labelText: widget.labelText,
              hintText: _controller.getTags is List ? '' : widget.hintText,
              helperText: widget.helperText ?? l10n!.textFieldChipsHelperText,
              errorText: inputFieldValues.error,
              prefixIcon: inputFieldValues.tags.isNotEmpty
                  ? Wrap(
                      spacing: 6,
                      runSpacing: 0,
                      alignment: WrapAlignment.start,
                      children: [
                        ...(widget.initialChips ?? []).map(
                          (String tag) {
                            final value = tag.capitalize();

                            return InputChip(
                              selected: true,
                              showCheckmark: false,
                              label: Text(value),
                              visualDensity: VisualDensity.compact,
                              deleteIcon: const Icon(
                                Icons.cancel,
                                size: 20,
                              ),
                              onDeleted: () {
                                inputFieldValues.onTagRemoved(value);
                                widget.onDeleted!(value);
                              },
                            );
                          },
                        ),
                        const SizedBox(width: 2)
                      ],
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}
