import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:red_flags/extensions/firestore_extension.dart';
import 'package:red_flags/models/qod.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/widgets/banner_user.dart';
import 'package:red_flags/widgets/cached_image.dart';
import 'package:red_flags/widgets/card/card_qod.dart';
import 'package:red_flags/widgets/profile/user_profile_details.dart';
import 'package:red_flags/widgets/qod_calendar.dart';
import 'package:red_flags/widgets/qod_content.dart';

//** Internal widget */
class _PageFullProfileViewTab extends StatefulWidget {
  const _PageFullProfileViewTab({
    required this.name,
    required this.qodCollectionRef,
  });

  final String name;
  final CollectionReference<QodModel> qodCollectionRef;

  @override
  State<_PageFullProfileViewTab> createState() =>
      _PageFullProfileViewTabState();
}

class _PageFullProfileViewTabState extends State<_PageFullProfileViewTab> {
  @override
  PreferredSizeWidget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Tab(
      child: SizedBox(
        width: 120,
        child: Text.rich(
          textAlign: TextAlign.center,
          TextSpan(
            children: [
              TextSpan(text: widget.name),
              if (widget.name == l10n!.questionOfDay)
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: FutureBuilder(
                    future: widget.qodCollectionRef.getCacheFirst(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.docs.length;

                      if (snapshot.hasData && count != null) {
                        return Badge(
                          label: Text(count.toString()),
                          offset: const Offset(10, -6),
                          child: const Text(' '),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

//** Internal widget */

class _PageFullProfileQodView extends StatefulWidget {
  const _PageFullProfileQodView({
    required this.userModel,
    required this.qodCollectionRef,
  });

  final UserModel userModel;
  final CollectionReference<QodModel> qodCollectionRef;

  @override
  State<_PageFullProfileQodView> createState() =>
      _PageFullProfileQodViewState();
}

class _PageFullProfileQodViewState extends State<_PageFullProfileQodView> {
  bool _visible = false;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _visible = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 24,
      ),
      child: FutureBuilder(
        future: widget.qodCollectionRef
            .orderBy(QodFields.createdAt.name, descending: true)
            .getCacheFirst(),
        builder: (context, snapshot) {
          final qods = snapshot.data?.docs;

          final firstDay = qods?.lastOrNull?.data().createdAt ?? DateTime.now();

          return StatefulBuilder(
            builder: (context, setState) {
              final selectedQods = qods?.where((qod) {
                final createdAt = qod.data().createdAt;

                return _rangeStart == null ||
                    _rangeEnd == null ||
                    (_rangeStart != null &&
                        createdAt.isAfter(_rangeStart!) &&
                        _rangeEnd != null &&
                        createdAt.isBefore(_rangeEnd!));
              }).toList();

              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  QodCalendar(
                    firstDay: firstDay,
                    lastDay: DateTime.now(),
                    onRangeSelected: (start, end, focusedDay) {
                      if (start != null) {
                        /// Ignore time due to timezone difference.
                        /// TableCalendar always calls back UTC but createdAt
                        /// of QoD is saved by user's timezone.
                        _rangeStart =
                            DateTime(start.year, start.month, start.day)
                                .toLocal();
                      }

                      if (end != null) {
                        _rangeEnd = DateTime(end.year, end.month, end.day + 1)
                            .toLocal();
                      }

                      if (start != null && end != null) {
                        setState(() {
                          _visible = false;
                        });

                        Future.delayed(const Duration(milliseconds: 100), () {
                          setState(() {
                            _visible = true;
                          });
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  !snapshot.hasData
                      ? LoadingAnimationWidget.threeArchedCircle(
                          color: theme.colorScheme.primary,
                          size: 32,
                        )
                      : Wrap(
                          spacing: 4,
                          children: List.generate(
                            selectedQods?.length ?? 0,
                            (index) {
                              final docSnapshot = selectedQods![index];

                              return AnimatedOpacity(
                                opacity: _visible ? 1 : 0,
                                duration: const Duration(milliseconds: 500),
                                child: CardQod(
                                  userModel: widget.userModel,
                                  qodSnapshot: docSnapshot,
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      showDragHandle: true,
                                      useSafeArea: true,
                                      isScrollControlled: true,
                                      builder: (context) {
                                        return QodContent(
                                          qodSnapshot: docSnapshot,
                                          userModel: widget.userModel,
                                        );
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

//** External widget */

class PageFullProfileView extends StatefulWidget {
  const PageFullProfileView({
    super.key,
    required this.userModel,
    this.qodCollectionRef,
  });

  final UserModel userModel;
  final CollectionReference<QodModel>? qodCollectionRef;

  @override
  State<PageFullProfileView> createState() => _PageFullProfileViewState();
}

class _PageFullProfileViewState extends State<PageFullProfileView> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tabs = [l10n!.profile];
    final qodCollectionRef = widget.qodCollectionRef;
    final hasQod = qodCollectionRef != null;

    if (hasQod) {
      tabs.add(l10n.questionOfDay);
    }

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
                sliver: SliverAppBar(
                  pinned: true,
                  primary: false,
                  expandedHeight: !hasQod ? 360 : 320,
                  collapsedHeight: !hasQod ? 240 : 300,
                  automaticallyImplyLeading: false,
                  forceElevated: innerBoxIsScrolled,
                  flexibleSpace: Stack(
                    children: [
                      CachedImage(
                        photoUrl: widget.userModel.photoUrl,
                        height: !hasQod ? 360 : 300,
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
                              stops: const [0, 0.4],
                              colors: [
                                theme.colorScheme.shadow.withOpacity(0.7),
                                theme.colorScheme.shadow.withOpacity(0)
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 20,
                        right: 20,
                        child: BannerUser(
                          userModel: widget.userModel,
                        ),
                      ),
                      Positioned(
                        left: 16,
                        top: 40,
                        child: Semantics(
                          button: true,
                          label: l10n.back,
                          child: IconButton.filled(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          ),
                        ),
                      ),
                    ],
                  ),
                  bottom: hasQod
                      ? TabBar(
                          tabs: tabs
                              .map(
                                (name) => _PageFullProfileViewTab(
                                  name: name,
                                  qodCollectionRef: qodCollectionRef,
                                ),
                              )
                              .toList(),
                        )
                      : null,
                ),
              ),
            ];
          },
          body: TabBarView(
            children: tabs
                .map(
                  (name) => SafeArea(
                    top: false,
                    bottom: false,
                    child: Builder(
                      builder: (context) {
                        return CustomScrollView(
                          key: PageStorageKey<String>(name),
                          slivers: <Widget>[
                            SliverOverlapInjector(
                              handle: NestedScrollView
                                  .sliverOverlapAbsorberHandleFor(
                                context,
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: name == l10n.profile
                                  ? UserProfileDetails(
                                      userModel: widget.userModel,
                                    )
                                  : name == l10n.questionOfDay && hasQod
                                      ? _PageFullProfileQodView(
                                          userModel: widget.userModel,
                                          qodCollectionRef: qodCollectionRef,
                                        )
                                      : null,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
