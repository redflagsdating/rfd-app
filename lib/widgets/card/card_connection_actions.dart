import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/mixins/mixin_qod.dart';
import 'package:red_flags/models/connection.dart';
import 'package:red_flags/models/qod.dart';
import 'package:red_flags/models/qod_answer.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/pages/page_freechat.dart';
import 'package:red_flags/pages/page_opt_in_date_splash.dart';
import 'package:red_flags/services/logger_provider.dart';
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
    required this.connectionSnapshot,
  });

  final UserModel userModel;
  final String connectionId;
  final QueryDocumentSnapshot<QodModel> lastQodSnapshot;
  final DocumentSnapshot<ConnectionModel> connectionSnapshot;

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
            qodSnapshot: widget.lastQodSnapshot,
            userModel: widget.userModel,
          ),
        );
      },
    );
  }

  Future<void> _optInDate(String myUid) async {
    bool bothOptedIn = false;
    final logger = context.read<LoggerProvider>().logger;

    try {
      await FirebaseFirestore.instance.runTransaction(
        (transaction) async {
          final connectionRef = widget.connectionSnapshot.reference;
          final snapshot = await transaction.get(connectionRef);
          final optedInUids = (snapshot.data()?.optedInUids ?? []);

          if (!optedInUids.contains(myUid)) {
            optedInUids.add(myUid);
          }

          bothOptedIn = optedInUids.length >= 2;

          transaction.update(connectionRef, {"optedInUids": optedInUids});
        },
      );

      // ignore: use_build_context_synchronously
      Navigator.of(context).push(
        PageFadeRouteBuilder(
          page: Builder(
            builder: (context) => PageOptInDateSplash(
              userModel: widget.userModel,
              connectionId: widget.connectionId,
              bothOptedIn: bothOptedIn,
            ),
          ),
        ),
      );
    } catch (e) {
      logger.e(e, time: DateTime.now());

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
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
            final myUid = userProvider.getIdCache();
            final isWaitingYours = status == QodStatus.unanswered ||
                isAwaitingByThem(qodSnapshot, myUid);
            final qodBtnLabel = isWaitingYours
                ? l10n!.cardConnectionBtnAnswerQod
                : l10n!.cardConnectionBtnViewQod;
            final optedInUids = widget.connectionSnapshot.data()?.optedInUids;
            final meOptedInOnly = optedInUids != null &&
                optedInUids.length == 1 &&
                optedInUids.contains(myUid);
            final bothOptedIn = optedInUids != null &&
                optedInUids.contains(myUid) &&
                optedInUids.contains(widget.userModel.uid);

            return FadeThroughTransitionSwitcher(
              child: !snapshot.hasData
                  ? const SizedBox(height: 48)
                  : status == QodStatus.unanswered || isWaitingYours
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
                            bothOptedIn || meOptedInOnly
                                ? Semantics(
                                    label: l10n.cardConnectionBtnFreeChat,
                                    child: FilledButton.icon(
                                      icon: const FaIcon(
                                        FontAwesomeIcons.comment,
                                      ),
                                      onPressed: meOptedInOnly
                                          ? null
                                          : () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PageFreeChat(
                                                    connectionId:
                                                        widget.connectionId,
                                                    userModel: widget.userModel,
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
                                      label: Text(
                                        l10n.cardConnectionBtnFreeChat,
                                      ),
                                    ),
                                  )
                                : Semantics(
                                    label: l10n.cardConnectionBtnGoOnDate,
                                    child: FilledButton(
                                      onPressed: () => _optInDate(myUid),
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
                                      child: Text(
                                        l10n.cardConnectionBtnGoOnDate,
                                      ),
                                    ),
                                  )
                          ],
                        ),
            );
          },
        ),
      ],
    );
  }
}
