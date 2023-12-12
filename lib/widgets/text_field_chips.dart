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
  late TextfieldTagsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextfieldTagsController();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return TextFieldTags(
      textfieldTagsController: _controller,
      initialTags: widget.initialChips,
      letterCase: LetterCase.normal,
      textSeparators: const [','],
      validator: widget.validator,
      inputfieldBuilder:
          (context, controller, focusNode, error, onChanged, onSubmitted) {
        return ((context, sc, tags, onTagDelete) {
          return TextField(
            readOnly: widget.readOnly ?? false,
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            maxLength: 20,
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              labelText: widget.labelText,
              hintText: _controller.hasTags ? '' : widget.hintText,
              helperText: widget.helperText ?? l10n!.textFieldChipsHelperText,
              errorText: error,
              prefixIcon: tags.isNotEmpty
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
                              deleteIcon: const Icon(
                                Icons.cancel,
                                size: 20,
                              ),
                              onDeleted: () {
                                onTagDelete(value);
                                widget.onDeleted!(value);
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 2)
                      ],
                    )
                  : null,
            ),
          );
        });
      },
    );
  }
}
