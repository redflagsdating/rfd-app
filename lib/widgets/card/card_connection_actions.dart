import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/mixins/mixin_qod.dart';
import 'package:red_flags/models/qod.dart';
import 'package:red_flags/models/qod_answer.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/pages/page_freechat.dart';
import 'package:red_flags/pages/page_freechat_splash.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/animation/fade_through_transition_switcher.dart';
import 'package:red_flags/widgets/animation/page_fade_route_builder.dart';
import 'package:red_flags/widgets/label/label_qod_status.dart';
import 'package:red_flags/widgets/qod_content.dart';

class CardConnectionActions extends StatefulWidget {
  const CardConnectionActions({
    super.key,
    required this.userModel,
    required this.connectionId,
    required this.lastQodSnapshot,
    this.enableChat,
  });

  final UserModel userModel;
  final String connectionId;
  final QueryDocumentSnapshot<QodModel> lastQodSnapshot;
  final bool? enableChat;

  @override
  State<CardConnectionActions> createState() => CardConnectionActionsState();
}

class CardConnectionActionsState extends State<CardConnectionActions>
    with MixinQod {
  late ScaffoldMessengerState _scaffoldMessenger;

  @override
  void didChangeDependencies() {
    _scaffoldMessenger = ScaffoldMessenger.of(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _scaffoldMessenger.clearMaterialBanners();
    super.dispose();
  }

  Future<void> _showQod() {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        // Wrapped inside Scaffold mainly for Snackbar
        return Scaffold(
          body: QodContent(
            qodModel: widget.lastQodSnapshot.data(),
            qodDocRef: widget.lastQodSnapshot.reference,
            userModel: widget.userModel,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final lastQodDocRef = widget.lastQodSnapshot.reference;
    final lastQodModel = widget.lastQodSnapshot.data();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Tight LabelQodStatus in this context mainly for setState to trigger
        /// refresh the widget
        LabelQodStatus(
          displayName: widget.userModel.displayName ?? '',
          qodDocRef: lastQodDocRef,
        ),
        const SizedBox(height: 8),
        StreamBuilder(
          stream: qodAnswerRef(lastQodDocRef).snapshots(),
          builder: (context, snapshot) {
            final qodSnapshot = snapshot.data;
            final status = getQodStatus(qodSnapshot);
            final isWaitingYours = status == QodStatus.unanswered ||
                isAwaitingByThem(qodSnapshot, userProvider.getIdCache());
            final qodBtnLabel = isWaitingYours
                ? l10n!.cardConnectionBtnAnswerQod
                : l10n!.cardConnectionBtnViewQod;

            return FadeThroughTransitionSwitcher(
              child: !snapshot.hasData
                  ? const SizedBox(height: 48)
                  : status != QodStatus.answered
                      ? Semantics(
                          label: qodBtnLabel,
                          child: FilledButton(
                            onPressed: () async {
                              await _showQod();
                              // Refresh widget on closed to reflect answer
                              if (isWaitingYours) {
                                setState(() {});
                              }
                            },
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  qodBtnLabel,
                                  style: theme.textTheme
                                      .apply(
                                        fontSizeFactor: 1.1,
                                        bodyColor: theme.colorScheme.onPrimary,
                                      )
                                      .labelLarge,
                                ),
                                Text(
                                  l10n.cardConnectionBtnDescription(
                                    lastQodModel.createdAt
                                        .add(
                                          const Duration(days: 1),
                                        )
                                        .difference(DateTime.now())
                                        .inHours,
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w400,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Semantics(
                              label: l10n.cardConnectionBtnViewQod,
                              child: OutlinedButton(
                                onPressed: _showQod,
                                style: FilledButton.styleFrom(
                                  // Don't go over 16 mainly for iPhone smallest screen
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                ),
                                child: Text(l10n.cardConnectionBtnViewQod),
                              ),
                            ),
                            Semantics(
                              label: l10n.cardConnectionBtnFreeChat,
                              child: IconButton.filled(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    widget.enableChat == true
                                        ? MaterialPageRoute(
                                            builder: (context) => PageFreeChat(
                                              connectionId: widget.connectionId,
                                              userModel: widget.userModel,
                                            ),
                                          )
                                        : PageFadeRouteBuilder(
                                            page: Builder(
                                              builder: (context) =>
                                                  PageFreeChatSplash(
                                                displayName: widget.userModel
                                                        .displayName ??
                                                    '',
                                              ),
                                            ),
                                          ),
                                  );
                                },
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                ),
                                icon: const FaIcon(FontAwesomeIcons.comment),
                              ),
                            ),
                            // TODO: Post MVP schedule a date
                            // Semantics(
                            //   label: l10n.cardConnectionBtnGoOnDate,
                            //   child: FilledButton(
                            //     onPressed: () {
                            //       // TODO: Go on a date integration
                            //     },
                            //     style: FilledButton.styleFrom(
                            //       padding: const EdgeInsets.symmetric(
                            //           horizontal: 16),
                            //       shape: const RoundedRectangleBorder(
                            //         borderRadius:
                            //             BorderRadius.all(Radius.circular(8)),
                            //       ),
                            //     ),
                            //     child: Text(l10n.cardConnectionBtnGoOnDate),
                            //   ),
                            // ),
                          ],
                        ),
            );
          },
        ),
      ],
    );
  }
}
