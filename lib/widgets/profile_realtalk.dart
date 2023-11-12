import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/models/question.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/card_realtalk.dart';
import 'package:red_flags/widgets/listview_questions.dart';
import 'package:red_flags/widgets/page_slide_transition_switcher.dart';
import 'package:red_flags/widgets/question_editor.dart';

class ProfileRealTalk extends StatefulWidget {
  const ProfileRealTalk({Key? key}) : super(key: key);

  @override
  State<ProfileRealTalk> createState() => _ProfileRealTalkState();
}

class _ProfileRealTalkState extends State<ProfileRealTalk> {
  bool? _updating = false;
  String? _currentQuestion;
  late UserProvider _userProvider;
  final List<String> _selected = [];
  final _currentAnswerCtrl = TextEditingController();

  void setUpdating(bool value) {
    setState(() {
      _updating = value;
    });
  }

  void setCurrentQuestion([String? question]) {
    setState(() {
      _currentQuestion = question;
    });
  }

  void _onEditingComplete() async {
    setUpdating(true);

    final realTalk = _userProvider.getRealTalkCache();

    if (realTalk != null) {
      realTalk[_currentQuestion as String] = _currentAnswerCtrl.text;
      await _userProvider.setRealTalk(
        realTalk,
      );
    } else {
      await _userProvider.setRealTalk(
        {_currentQuestion!: _currentAnswerCtrl.text},
      );
    }

    setUpdating(false);
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }

  void _onTap() {
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
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: PageSlideTransitionSwitcher(
                child: _currentQuestion != null
                    ? QuestionEditor(
                        enabled: _updating != true,
                        question: _currentQuestion!,
                        controller: _currentAnswerCtrl,
                        onBack: _currentQuestion != null
                            ? null
                            : () {
                                setState(() {
                                  _currentQuestion = null;
                                  _currentAnswerCtrl.clear();
                                });
                              },
                        onEditingComplete: _onEditingComplete,
                      )
                    : ListViewQuestions(
                        questions: QuestionModel.questions,
                        selected: _selected,
                        onSelect: (question) {
                          // Using setState from StatefulBuilder
                          setState(() {
                            _currentQuestion = question;
                            _currentAnswerCtrl.clear();
                          });
                        },
                      ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final realTalk = _userProvider.getRealTalkCache();

    MapEntry<String, String>? firstQuestion;
    MapEntry<String, String>? secondQuestion;
    MapEntry<String, String>? thirdQuestion;

    if (realTalk != null) {
      firstQuestion = realTalk.entries.first;
      secondQuestion =
          realTalk.length > 1 ? realTalk.entries.elementAt(1) : null;
      thirdQuestion =
          realTalk.length > 2 ? realTalk.entries.elementAt(1) : null;

      _selected.addAll(realTalk.keys);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n!.pgRealTalkHeadline,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Text(l10n.pgRealTalkBody),
        const SizedBox(height: 20),
        CardRealTalk(
          question: firstQuestion?.key,
          answer: firstQuestion?.value,
          onTap: () {
            setCurrentQuestion(firstQuestion?.key);
            _currentAnswerCtrl.text = firstQuestion?.value ?? "";
            _onTap();
          },
          onLongPress: () {
            final question = firstQuestion?.key;

            if (question != null && realTalk != null) {
              realTalk.remove(question);
              _userProvider.setRealTalk(
                realTalk,
              );

              setState(() {});
            }
          },
        ),
        CardRealTalk(
          question: secondQuestion?.key,
          answer: secondQuestion?.value,
          onTap: () {
            setCurrentQuestion(secondQuestion?.key);
            _currentAnswerCtrl.text = secondQuestion?.value ?? "";
            _onTap();
          },
          onLongPress: () {
            final question = secondQuestion?.key;

            if (question != null && realTalk != null) {
              realTalk.remove(question);
              _userProvider.setRealTalk(
                realTalk,
              );

              setState(() {});
            }
          },
        ),
        CardRealTalk(
          question: thirdQuestion?.key,
          answer: thirdQuestion?.value,
          onTap: () {
            setCurrentQuestion(thirdQuestion?.key);
            _currentAnswerCtrl.text = thirdQuestion?.value ?? "";
            _onTap();
          },
          onLongPress: () {
            final question = thirdQuestion?.key;

            if (question != null && realTalk != null) {
              realTalk.remove(question);
              _userProvider.setRealTalk(
                realTalk,
                localOnly: true,
                silent: true,
              );

              setState(() {});
            }
          },
        ),
      ],
    );
  }
}
