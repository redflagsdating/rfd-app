import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:red_flags/mixins/mixin_qod.dart';
import 'package:red_flags/models/qod.dart';
import 'package:red_flags/models/user.dart';

class QodContent extends StatefulWidget {
  const QodContent({
    super.key,
    required this.qodModel,
    required this.userModel,
  });

  final QodModel qodModel;
  final UserModel userModel;

  @override
  State<QodContent> createState() => _QodContentState();
}

class _QodContentState extends State<QodContent> with MixinQod {
  // final _form = GlobalKey<FormState>();
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
    // final userProvider = Provider.of<UserProvider>(context);
    // final primaryAnswer = widget.qod.primaryUserAnswer;
    // final secondaryAnswer = widget.qod.secondaryUserAnswer;
    // final isSecondaryAnswered =
    //     widget.qod.status == QodStatus.secondaryAnswered;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Chip(
                label: Text(
                  l10n!.questionOfDay,
                  style: theme.textTheme
                      .apply(bodyColor: theme.colorScheme.onPrimary)
                      .labelLarge,
                ),
                visualDensity: VisualDensity.compact,
                side: MaterialStateBorderSide.resolveWith((states) {
                  return const BorderSide(color: Colors.transparent);
                }),
                color: MaterialStateProperty.resolveWith(
                  (states) {
                    return theme.colorScheme.primary;
                  },
                ),
              ),
            ],
          ),
          Text(
            widget.qodModel.question,
            semanticsLabel: widget.qodModel.question,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 20),
          // if (primaryAnswer != null)
          //   CardQodAnswer(
          //     answer: primaryAnswer,
          //     photoUrl: userProvider.getPhotoUrlCache(),
          //   ),
          // if (widget.qod.status == QodStatus.answered)
          //   const SizedBox(height: 10),
          // if (secondaryAnswer != null)
          //   CardQodAnswer(
          //     answer: secondaryAnswer,
          //     locked: isSecondaryAnswered,
          //     photoUrl: widget.userModel.photoUrl,
          //   ),
          // const SizedBox(height: 20),
          // // LabelQodStatus(qod: widget.qod, fontSize: 14),
          // const Spacer(),
          // if (isSecondaryAnswered)
          //   Form(
          //     key: _form,
          //     child: ConstrainedBox(
          //       constraints: const BoxConstraints(maxHeight: 110),
          //       child: TextFormField(
          //         enabled: true,
          //         maxLines: null,
          //         controller: _controller,
          //         autovalidateMode: AutovalidateMode.onUserInteraction,
          //         decoration: InputDecoration(
          //           filled: true,
          //           isDense: true,
          //           suffixIcon: InkWell(
          //             child: Icon(
          //               Icons.send_rounded,
          //               size: 28,
          //               color: theme.colorScheme.primary,
          //             ),
          //             onTap: () {
          //               if (!_form.currentState!.validate()) {
          //                 return;
          //               }

          //               // TODO: QoD answer integration
          //             },
          //           ),
          //           border: const OutlineInputBorder(
          //             borderSide: BorderSide.none,
          //             borderRadius: BorderRadius.all(Radius.circular(8.0)),
          //           ),
          //           hintText: l10n.fieldQodResponseHintText,
          //         ),
          //         validator: (value) {
          //           if (value == null || value.trim().isEmpty) {
          //             return l10n.fieldQodResponseEmptyErrorText;
          //           }

          //           return null;
          //         },
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}
