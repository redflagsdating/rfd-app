import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:red_flags/widgets/card/card_realtalk.dart';

import '../global.dart' as global;

void main() {
  // CardRealTalk widget
  const gestureKey = Key("card_realtalk_gesture_detector");
  const containerKey = Key("card_realtalk_container");
  const emptyBoxKey = Key("card_realtalk_empty_box");
  const listKey = Key("card_realtalk_list_questions");

  // ListViewQuestions widget
  const listItemKey = Key("listview_questions_item_card");

  // realtalkEditor widget
  const editorTitleKey = Key("realtalk_editor_display_title");
  const editorSaveKey = Key("realtalk_editor_save_button");
  const editorDeleteKey = Key("realtalk_editor_delete_button");
  const textfieldKey = Key("realtalk_editor_textfield");

  final question = global.userModel.realTalk?.entries.first.key;
  final answer = global.userModel.realTalk?.entries.first.value;

  testWidgets(
    "CardRealTalk/RealTalkEditor widgets > Adding question scenario",
    (widgetTester) async {
      final addCompleter = Completer();

      await widgetTester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return CardRealTalk(
                    listQuestions: [question!],
                    hintText: global.l10n.brandName,
                    onAdded: (q, answer) {
                      if (q == question && answer.length >= 100) {
                        addCompleter.complete();
                      }
                    });
              },
            ),
          ),
        ),
      );

      // Test hintText
      expect(find.text(global.l10n.brandName), findsOneWidget);
      expect(find.byKey(listKey), findsNothing);
      expect(find.byKey(containerKey), findsNothing);

      // Test open list of questions bottom sheet
      await widgetTester.tap(find.byKey(emptyBoxKey));
      await widgetTester.pump();
      expect(find.byKey(listKey), findsOneWidget);
      expect(find.text(question!), findsOneWidget);

      /// When widget contains scrollable content (e.g. ListView.builder)
      await widgetTester.ensureVisible(find.byKey(listItemKey));
      await widgetTester.pumpAndSettle();
      await widgetTester.tap(find.byKey(listItemKey));
      await widgetTester.pump();
      expect(find.text(global.l10n.realtalkEditorTitle), findsOneWidget);
      expect(find.byKey(editorTitleKey), findsOneWidget);
      expect(find.text(global.l10n.realtalkEditorHintText), findsOneWidget);
      expect(find.text('0/250'), findsOneWidget);

      expect(
        find.text(global.l10n.realtalkEditorEmptyErrorText),
        findsNothing,
      );
      await widgetTester.tap(find.byKey(editorSaveKey));
      await widgetTester.pump();
      expect(
        find.text(global.l10n.realtalkEditorEmptyErrorText),
        findsOneWidget,
      );

      // Error handling - less than 100 characters
      await widgetTester.enterText(
        find.byKey(textfieldKey),
        answer!.substring(1, 99),
      );
      await widgetTester.tap(find.byKey(editorSaveKey));
      await widgetTester.pump();
      expect(
        find.text(global.l10n.realtalkEditorShortErrorText),
        findsOneWidget,
      );

      // Successfully added a question with an answer
      expect(addCompleter.isCompleted, isFalse);
      await widgetTester.enterText(find.byKey(textfieldKey), answer);
      await widgetTester.tap(find.byKey(editorSaveKey));
      await widgetTester.pump();
      expect(addCompleter.isCompleted, isTrue);

      // Test CardRealTalk contains ellipsis question and answer for preview
      expect(find.byKey(containerKey), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(containerKey),
          matching: find.textContaining(question.substring(1, 10)),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(containerKey),
          matching: find.textContaining(
            question.substring(1, 40),
          ),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    "CardRealTalk/RealTalkEditor widgets > Delete initialQuestion/initialAnswer",
    (widgetTester) async {
      final deleteCompleter = Completer();

      await widgetTester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return CardRealTalk(
                  listQuestions: [question!],
                  selectedQuestions: [question],
                  initialQuestion: question,
                  initialAnswer: answer,
                  hintText: global.l10n.brandName,
                  onDeleted: (q) {
                    if (q == question) {
                      deleteCompleter.complete();
                    }
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text(global.l10n.brandName), findsNothing);
      expect(find.byKey(containerKey), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(containerKey),
          matching: find.textContaining(question!.substring(1, 10)),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(containerKey),
          matching: find.textContaining(
            answer!.substring(1, 40),
          ),
        ),
        findsOneWidget,
      );

      // Test realtalkEditor inline delete question
      expect(deleteCompleter.isCompleted, isFalse);
      await widgetTester.tap(find.byKey(gestureKey));
      await widgetTester.pump();
      await widgetTester.ensureVisible(find.byKey(editorTitleKey));
      await widgetTester.pumpAndSettle();
      await widgetTester.tap(find.byKey(editorDeleteKey));
      await widgetTester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);

      await widgetTester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(global.l10n.delete),
        ),
      );
      await widgetTester.pump();
      expect(deleteCompleter.isCompleted, isTrue);
    },
  );

  testWidgets(
    "CardRealTalk widget > longPress to delete question",
    (widgetTester) async {
      final deleteCompleter = Completer();

      await widgetTester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return CardRealTalk(
                  listQuestions: [question!],
                  hintText: global.l10n.brandName,
                  onDeleted: (q) {
                    if (q == question) {
                      deleteCompleter.complete();
                    }
                  },
                );
              },
            ),
          ),
        ),
      );

      await widgetTester.tap(find.byKey(emptyBoxKey));
      await widgetTester.pump();
      await widgetTester.ensureVisible(find.byKey(listItemKey));
      await widgetTester.pumpAndSettle();
      await widgetTester.tap(find.byKey(listItemKey));
      await widgetTester.pump();
      await widgetTester.enterText(find.byKey(textfieldKey), answer!);
      await widgetTester.tap(find.byKey(editorSaveKey));
      await widgetTester.pump();

      await widgetTester.longPress(find.byKey(gestureKey));
      await widgetTester.pump();

      // Test AlertDialog
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(global.l10n.dialogDeleteRealTalkCardTitle),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(global.l10n.dialogDeleteRealTalkCardBody),
        ),
        findsOneWidget,
      );

      // AlertDialog - cancel button
      await widgetTester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(global.l10n.cancel),
        ),
      );
      await widgetTester.pump();
      expect(find.byType(AlertDialog), findsNothing);

      // Alert Dialog - delete button
      expect(deleteCompleter.isCompleted, isFalse);
      await widgetTester.longPress(find.byKey(gestureKey));
      await widgetTester.pump();
      await widgetTester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text(global.l10n.delete),
        ),
      );
      await widgetTester.pump();
      expect(deleteCompleter.isCompleted, isTrue);
    },
  );
}
