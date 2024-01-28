import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/extensions/firestore_extension.dart';
import 'package:red_flags/mixins/mixin_qod.dart';
import 'package:red_flags/models/qod.dart';
import 'package:red_flags/models/qod_answer.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/card/card_qod_answer.dart';
import 'package:red_flags/widgets/label/label_qod_status.dart';

class QodContent extends StatefulWidget {
  const QodContent({
    super.key,
    required this.qodModel,
    required this.userModel,
    required this.qodDocRef,
  });

  final QodModel qodModel;
  final UserModel userModel;
  final DocumentReference<QodModel> qodDocRef;

  @override
  State<QodContent> createState() => _QodContentState();
}

class _QodContentState extends State<QodContent> with MixinQod {
  bool _enabled = true;
  final _form = GlobalKey<FormState>();
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
    final userProvider = Provider.of<UserProvider>(context);
    final answerCollectionRef = qodAnswerRef(widget.qodDocRef);

    final slivers = [
      SliverFillRemaining(
        hasScrollBody: false,
        child: FutureBuilder(
          future: answerCollectionRef.getCacheFirst(),
          builder: (context, snapshot) {
            final myUid = userProvider.getIdCache();
            final querySnapshot = snapshot.data;
            final isWaitingYours = isAwaitingByThem(querySnapshot, myUid);
            final myQodAnswer = getQodAnswerById(querySnapshot, myUid);
            final theirQodAnswer =
                getQodAnswerById(querySnapshot, widget.userModel.uid);

            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            if (myQodAnswer != null) {
              _controller.text = myQodAnswer.data().answer;
            }

            Future<void> onSaveAnswer() async {
              if (!_form.currentState!.validate()) {
                return;
              }

              setState(() {
                _enabled = false;
              });

              if (myQodAnswer != null) {
                // Update the existing answer within 24 hours
                await myQodAnswer.reference.update({
                  "answer": _controller.text,
                  "answeredAt": DateTime.now(),
                });
              } else {
                // Add answer to the QoD
                await answerCollectionRef.add(
                  QodAnswerModel(
                    uid: myUid,
                    answer: _controller.text,
                    answeredAt: DateTime.now(),
                  ),
                );
              }

              setState(() {
                _enabled = true;
              });
            }

            return Column(
              children: [
                if (theirQodAnswer != null)
                  CardQodAnswer(
                    answer: theirQodAnswer.data().answer,
                    locked: isWaitingYours,
                    photoUrl: widget.userModel.photoUrl,
                  ),
                if (getQodStatus(querySnapshot) == QodStatus.answered)
                  const SizedBox(height: 10),
                if (myQodAnswer != null)
                  CardQodAnswer(
                    answer: myQodAnswer.data().answer,
                    photoUrl: userProvider.getPhotoUrlCache(),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: LabelQodStatus(
                      displayName: widget.userModel.displayName ?? '',
                      qodDocRef: widget.qodDocRef,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (isWaitingYours || isQodNew(widget.qodModel))
                  Form(
                    key: _form,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 130),
                      child: TextFormField(
                        enabled: _enabled,
                        // Auto max lines based on height
                        maxLines: null,
                        maxLength: 250,
                        controller: _controller,
                        textCapitalization: TextCapitalization.sentences,
                        autovalidateMode: AutovalidateMode.onUserInteraction,

                        decoration: InputDecoration(
                          filled: true,
                          isDense: true,
                          suffixIcon: InkWell(
                            onTap: _enabled ? onSaveAnswer : null,
                            child: Icon(
                              Icons.send_rounded,
                              size: 28,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                          ),
                          hintText: l10n!.fieldQodResponseHintText,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.fieldQodResponseEmptyErrorText;
                          }

                          return null;
                        },
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    ];

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
          Expanded(
            child: CustomScrollView(slivers: slivers),
          ),
        ],
      ),
    );
  }
}
