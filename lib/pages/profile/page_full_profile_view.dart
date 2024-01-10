import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/models/qod.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/banner_user.dart';
import 'package:red_flags/widgets/cached_image.dart';
import 'package:red_flags/widgets/card/card_qod.dart';
import 'package:red_flags/widgets/profile/user_profile_details.dart';
import 'package:red_flags/widgets/qod_content.dart';

class PageFullProfileView extends StatefulWidget {
  const PageFullProfileView({
    super.key,
    required this.userModel,
  });

  final UserModel userModel;

  @override
  State<PageFullProfileView> createState() => _PageFullProfileViewState();
}

class _PageFullProfileViewState extends State<PageFullProfileView>
    with TickerProviderStateMixin {
  late QodModel _qod;

  @override
  void initState() {
    // TODO: Dummy QoD
    _qod = QodModel(
      question: "What is something about you that surprises most people?",
      primaryUserId: widget.userModel.uid,
      primaryUserDisplayName: widget.userModel.displayName ?? '',
      primaryUserPhotoUrl: widget.userModel.photoUrl,
      secondaryUserId: widget.userModel.uid,
      secondaryDisplayName: widget.userModel.displayName ?? '',
      secondaryUserPhotoUrl: widget.userModel.photoUrl,
      secondaryUserAnswer:
          "This is my QoD answer for demo purpose. This is my QoD answer for demo purpose. This is my QoD answer for demo purpose.",
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final userProvider = context.read<UserProvider>();
    final tabs = [l10n!.profile];

    // Default assume self preview profile when uid is identical
    final isPreview = widget.userModel.uid == userProvider.getIdCache();

    if (!isPreview) {
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
                  expandedHeight: isPreview ? 360 : 320,
                  collapsedHeight: isPreview ? 240 : 300,
                  automaticallyImplyLeading: false,
                  forceElevated: innerBoxIsScrolled,
                  flexibleSpace: Stack(
                    children: [
                      CachedImage(
                        photoUrl: widget.userModel.photoUrl,
                        height: isPreview ? 360 : 300,
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
                  bottom: isPreview
                      ? null
                      : TabBar(
                          tabs: tabs
                              .map(
                                (name) => Tab(
                                  child: SizedBox(
                                    width: 120,
                                    child: Text(
                                      name,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
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
                                  // TODO: QoD integration
                                  : Container(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          CardQod(
                                            qod: _qod,
                                            onTap: () {
                                              showModalBottomSheet(
                                                context: context,
                                                showDragHandle: true,
                                                useSafeArea: true,
                                                isScrollControlled: true,
                                                builder: (context) {
                                                  return QodContent(qod: _qod);
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
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
