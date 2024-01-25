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
                      final isDone =
                          snapshot.connectionState == ConnectionState.done;
                      final count = snapshot.data?.docs.length;

                      if (isDone && count != null) {
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
            .orderBy(
              QodFields.createdAt.name,
              descending: true,
            )
            .getCacheFirst(),
        builder: (context, snapshot) {
          final qods = snapshot.data?.docs.firstOrNull;
          final isWaiting = snapshot.connectionState == ConnectionState.waiting;

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // TODO: Integration
              QodCalendar(
                firstDay: DateTime(2023, 12, 01),
                lastDay: DateTime.now(),
                onRangeSelected: (start, end, focusedDay) {
                  // TODO
                },
              ),
              const SizedBox(height: 32),
              isWaiting
                  ? LoadingAnimationWidget.threeArchedCircle(
                      color: theme.colorScheme.primary,
                      size: 32,
                    )
                  : CardQod(
                      qodModel: qods!.data(),
                      userModel: widget.userModel,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          showDragHandle: true,
                          useSafeArea: true,
                          isScrollControlled: true,
                          builder: (context) {
                            // TODO: Refactory
                            return QodContent(
                              qodModel: qods.data(),
                              userModel: widget.userModel,
                            );
                          },
                        );
                      },
                    ),
            ],
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

class _PageFullProfileViewState extends State<PageFullProfileView>
    with TickerProviderStateMixin {
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
