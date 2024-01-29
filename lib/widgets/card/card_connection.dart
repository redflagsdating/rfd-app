import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/extensions/firestore_extension.dart';
import 'package:red_flags/mixins/mixin_qod.dart';
import 'package:red_flags/models/connection.dart';
import 'package:red_flags/models/qod.dart';
import 'package:red_flags/models/qod_answer.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/pages/profile/page_full_profile_view.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/animation/fade_through_transition_switcher.dart';
import 'package:red_flags/widgets/animation/page_fade_route_builder.dart';
import 'package:red_flags/widgets/banner_user.dart';
import 'package:red_flags/widgets/cached_image.dart';
import 'package:red_flags/widgets/label/label_qod_status.dart';
import 'package:red_flags/widgets/qod_content.dart';

//* Internal widget */
class _CardConnectionPlaceholder extends StatelessWidget {
  const _CardConnectionPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 440,
      width: 310,
      child: Card(
        child: LoadingAnimationWidget.beat(
          color: theme.colorScheme.primaryContainer,
          size: 48,
        ),
      ),
    );
  }
}

//* Internal widget */
class _CardConnectionError extends StatelessWidget {
  const _CardConnectionError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 440,
      width: 310,
      child: Card(
        color: theme.colorScheme.errorContainer,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.onErrorContainer,
            ),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme
                  .apply(
                    bodyColor: theme.colorScheme.onErrorContainer,
                  )
                  .labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}

//* Internal widget */

class _CardConnectionActions extends StatefulWidget {
  const _CardConnectionActions({
    required this.qodModel,
    required this.qodDocRef,
    required this.userModel,
  });

  final UserModel userModel;
  final QodModel qodModel;
  final DocumentReference<QodModel> qodDocRef;

  @override
  State<_CardConnectionActions> createState() => _CardConnectionActionsState();
}

class _CardConnectionActionsState extends State<_CardConnectionActions>
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
            qodModel: widget.qodModel,
            qodDocRef: widget.qodDocRef,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Tight LabelQodStatus in this context mainly for setState to trigger
        /// refresh the widget
        LabelQodStatus(
          displayName: widget.userModel.displayName ?? '',
          qodDocRef: widget.qodDocRef,
        ),
        const SizedBox(height: 8),
        FutureBuilder(
          future: qodAnswerRef(widget.qodDocRef).getCacheFirst(),
          builder: (context, snapshot) {
            final qodSnapshot = snapshot.data;
            final status = getQodStatus(qodSnapshot);
            final isWaitingYours = status == QodStatus.unanswered ||
                isAwaitingByThem(qodSnapshot, userProvider.getIdCache());
            final qodBtnLabel = isWaitingYours
                ? l10n!.cardUserProfileAnswerBtn
                : l10n!.cardUserProfileViewResponseBtn;

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
                                  l10n.cardUserProfileAnswerBtnNote(
                                    DateTime.now()
                                        .difference(widget.qodModel.createdAt)
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
                              label: l10n.cardUserProfileViewResponseBtn,
                              child: OutlinedButton(
                                onPressed: _showQod,
                                style: FilledButton.styleFrom(
                                  // Don't go over 16 mainly for iPhone smallest screen
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                ),
                                child:
                                    Text(l10n.cardUserProfileViewResponseBtn),
                              ),
                            ),
                            Semantics(
                              label: l10n.btnGoOnDate,
                              child: FilledButton(
                                onPressed: () {
                                  // TODO: Go on a date integration

                                  // TODO: Placeholder for later integration
                                  _scaffoldMessenger.showMaterialBanner(
                                    MaterialBanner(
                                      content: const Text(
                                          'Hello, I am a Material Banner'),
                                      leading: Icon(
                                        Icons.agriculture_outlined,
                                        color: theme.colorScheme.onSecondary,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context)
                                                .hideCurrentMaterialBanner();
                                          },
                                          child: const Text('DISMISS'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                  ),
                                ),
                                child: Text(l10n.btnGoOnDate),
                              ),
                            ),
                          ],
                        ),
            );
          },
        ),
      ],
    );
  }
}

//** Internal widget */

class _CardConnectionContent extends StatefulWidget {
  const _CardConnectionContent({
    required this.userModel,
    required this.qodCollectionRef,
  });

  final UserModel userModel;
  final CollectionReference<QodModel> qodCollectionRef;

  @override
  State<_CardConnectionContent> createState() => _CardConnectionContentState();
}

class _CardConnectionContentState extends State<_CardConnectionContent> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            PageFadeRouteBuilder(
              page: Builder(
                builder: (context) => PageFullProfileView(
                  userModel: widget.userModel,
                  qodCollectionRef: widget.qodCollectionRef,
                ),
              ),
            ),
          );
        },
        child: Card(
          child: Column(
            children: [
              Stack(
                children: [
                  CachedImage(
                    photoUrl: widget.userModel.photoUrl,
                    height: 280,
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          stops: const [0, 0.3],
                          colors: [
                            theme.colorScheme.shadow.withOpacity(0.7),
                            theme.colorScheme.shadow.withOpacity(0)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 16,
                    right: 16,
                    child: BannerUser(
                      userModel: widget.userModel,
                      compact: true,
                    ),
                  )
                ],
              ),
              FutureBuilder(
                // Latest Qod of the connection
                future: widget.qodCollectionRef
                    .orderBy(
                      QodFields.createdAt.name,
                      descending: true,
                    )
                    .getCacheFirst(),
                builder: (context, snapshot) {
                  final latestQodSnapshot = snapshot.data?.docs.firstOrNull;
                  final latestQod = latestQodSnapshot?.data();

                  return FadeThroughTransitionSwitcher(
                    child: !snapshot.hasData
                        ? const SizedBox(height: 160)
                        : Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                latestQod != null
                                    ? Text(
                                        latestQod.question,
                                        maxLines: 3,
                                        style: theme.textTheme.titleMedium,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : Text(
                                        l10n!.cardConnectionEmptyQod,
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w300,
                                          color: theme.colorScheme.outline,
                                        ),
                                      ),
                                const SizedBox(height: 4),
                                if (latestQod != null)
                                  _CardConnectionActions(
                                    qodModel: latestQod,
                                    userModel: widget.userModel,
                                    qodDocRef: latestQodSnapshot!.reference,
                                  )
                              ],
                            ),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//** External widget */
class CardConnection extends StatefulWidget {
  const CardConnection({
    super.key,
    required this.id,
  });

  final String id;

  @override
  State<CardConnection> createState() => _CardConnectionState();
}

class _CardConnectionState extends State<CardConnection> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final qodCollectionRef = qodRef(widget.id);
    final connectionDocRef = connectionRef.doc(widget.id);

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 280,
        minHeight: 280,
        maxWidth: (MediaQuery.of(context).size.width * 0.8).ceil().toDouble(),
        maxHeight: (MediaQuery.of(context).size.height * 0.7).ceil().toDouble(),
      ),
      // Fetch connection document data
      child: FutureBuilder(
        future: connectionDocRef.getCacheFirst(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const _CardConnectionPlaceholder();
          }

          final connection = snapshot.data?.data();

          // Connection document data is empty
          if (connection == null) {
            final message = snapshot.hasError
                ? snapshot.error.toString()
                : l10n!.cardConnectionEmptyData(widget.id);

            return _CardConnectionError(message: message);
          }

          final uidMyself = userProvider.getIdCache();
          final uid = connection.uids.firstWhere(
            (uid) => uid != uidMyself,
          );

          return FutureBuilder(
            /// Exception use case not using userProvider.getUserModelById
            /// mainly to use getCacheFirst() extension function for server
            /// fallback.
            future: userProvider.usersRef
                .where(UserFields.uid.name, isEqualTo: uid)
                .getCacheFirst(),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs;
              final isEmpty = docs == null || docs.isEmpty;
              final message = snapshot.hasError
                  ? snapshot.error.toString()
                  : l10n!.cardConnectionEmptyUserData(uid);

              return !snapshot.hasData
                  ? const _CardConnectionPlaceholder()
                  : isEmpty
                      ? _CardConnectionError(message: message)
                      : _CardConnectionContent(
                          userModel: docs.first.data(),
                          qodCollectionRef: qodCollectionRef,
                        );
            },
          );
        },
      ),
    );
  }
}
