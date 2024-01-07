import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/models/question.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/card/card_realtalk.dart';

class ProfileRealTalk extends StatefulWidget {
  const ProfileRealTalk({super.key});

  @override
  State<ProfileRealTalk> createState() => _ProfileRealTalkState();
}

class _ProfileRealTalkState extends State<ProfileRealTalk> {
  late UserProvider _userProvider;
  final Set<String> _selected = {};

  void _onAdded(String question, String answer) async {
    final realTalk = _userProvider.getRealTalkCache();

    if (realTalk != null) {
      realTalk[question] = answer;
      await _userProvider.setRealTalk(realTalk);
    } else {
      await _userProvider.setRealTalk({question: answer});
    }

    setState(() {
      _selected.add(question);
    });
  }

  void _onDeleted(String question) async {
    final realTalk = _userProvider.getRealTalkCache();

    if (realTalk != null) {
      realTalk.remove(question);
      await _userProvider.setRealTalk(realTalk);
    }

    setState(() {
      _selected.remove(question);
    });
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

    MapEntry<String, String>? first;
    MapEntry<String, String>? second;
    MapEntry<String, String>? third;

    if (realTalk != null) {
      first = realTalk.entries.first;
      second = realTalk.length > 1 ? realTalk.entries.elementAt(1) : null;
      third = realTalk.length > 2 ? realTalk.entries.elementAt(2) : null;

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
          hintText: l10n.cardRealTalkText,
          initialQuestion: first?.key,
          initialAnswer: first?.value,
          listQuestions: QuestionModel.realtalk,
          selectedQuestions: _selected.toList(),
          onDeleted: _onDeleted,
          onAdded: _onAdded,
        ),
        const SizedBox(height: 10),
        CardRealTalk(
          hintText: l10n.cardRealTalkText,
          initialQuestion: second?.key,
          initialAnswer: second?.value,
          listQuestions: QuestionModel.realtalk,
          selectedQuestions: _selected.toList(),
          onDeleted: _onDeleted,
          onAdded: _onAdded,
        ),
        const SizedBox(height: 10),
        CardRealTalk(
          hintText: l10n.cardRealTalkText,
          initialQuestion: third?.key,
          initialAnswer: third?.value,
          listQuestions: QuestionModel.realtalk,
          selectedQuestions: _selected.toList(),
          onDeleted: _onDeleted,
          onAdded: _onAdded,
        ),
      ],
    );
  }
}
