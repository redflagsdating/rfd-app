import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:red_flags/models/qod.dart';
import 'package:red_flags/widgets/card/card_qod_answer.dart';
import 'package:red_flags/widgets/label/label_qod_status.dart';

class QodContent extends StatefulWidget {
  const QodContent({super.key, required this.qod});
  final QodModel qod;

  @override
  State<QodContent> createState() => _QodContentState();
}

class _QodContentState extends State<QodContent> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final primaryAnswer = widget.qod.primaryUserAnswer;
    final secondaryAnswer = widget.qod.secondaryUserAnswer;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            widget.qod.question,
            semanticsLabel: widget.qod.question,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          if (primaryAnswer != null)
            CardQodAnswer(
              answer: primaryAnswer,
              photoUrl: widget.qod.primaryUserPhotoUrl,
            ),
          if (widget.qod.status == QodStatus.answered)
            const SizedBox(height: 10),
          if (secondaryAnswer != null)
            CardQodAnswer(
              answer: secondaryAnswer,
              photoUrl: widget.qod.secondaryUserPhotoUrl,
            ),
          const SizedBox(height: 20),
          LabelQodStatus(qod: widget.qod, fontSize: 16),
          const Spacer(),
          if (widget.qod.status == QodStatus.secondaryAnswered)
            TextFormField(
              enabled: true,
              controller: _controller,
              decoration: InputDecoration(
                filled: true,
                isDense: true,
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                hintText: l10n!.fieldQodResponseHintText,
              ),
              validator: (value) {
                return null;
              },
            ),
        ],
      ),
    );
  }
}
