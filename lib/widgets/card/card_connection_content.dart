import 'package:flutter/material.dart';
import 'package:red_flags/models/qod.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/pages/profile/page_full_profile_view.dart';
import 'package:red_flags/widgets/animation/page_fade_route_builder.dart';
import 'package:red_flags/widgets/banner_user.dart';
import 'package:red_flags/widgets/cached_image.dart';
import 'package:red_flags/widgets/card/card_connection_actions.dart';

class CardConnectionContent extends StatefulWidget {
  const CardConnectionContent({
    super.key,
    required this.userModel,
    required this.connectionId,
  });

  final UserModel userModel;
  final String connectionId;

  @override
  State<CardConnectionContent> createState() => CardConnectionContentState();
}

class CardConnectionContentState extends State<CardConnectionContent> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final qodCollectionRef = qodRef(widget.connectionId);

    return SingleChildScrollView(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            PageFadeRouteBuilder(
              page: Builder(
                builder: (context) => PageFullProfileView(
                  userModel: widget.userModel,
                  qodCollectionRef: qodCollectionRef,
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
              StreamBuilder(
                // Latest Qod of the connection
                stream: qodCollectionRef
                    .orderBy(
                      QodFields.createdAt.name,
                      descending: true,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  final latestQodSnapshot = snapshot.data?.docs.firstOrNull;

                  return latestQodSnapshot == null || !latestQodSnapshot.exists
                      ? const SizedBox(height: 160)
                      : Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                latestQodSnapshot.data().question,
                                maxLines: 3,
                                style: theme.textTheme.titleMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              CardConnectionActions(
                                userModel: widget.userModel,
                                connectionId: widget.connectionId,
                                lastQodSnapshot: latestQodSnapshot,
                              )
                            ],
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
