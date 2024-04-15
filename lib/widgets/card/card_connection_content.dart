import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    required this.qodCollectionRef,
  });

  final UserModel userModel;
  final CollectionReference<QodModel> qodCollectionRef;

  @override
  State<CardConnectionContent> createState() => CardConnectionContentState();
}

class CardConnectionContentState extends State<CardConnectionContent> {
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
              StreamBuilder(
                // Latest Qod of the connection
                stream: widget.qodCollectionRef
                    .orderBy(
                      QodFields.createdAt.name,
                      descending: true,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  final latestQodSnapshot = snapshot.data?.docs.firstOrNull;
                  final latestQod = latestQodSnapshot?.data();

                  return !snapshot.hasData
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
                                CardConnectionActions(
                                  qodModel: latestQod,
                                  userModel: widget.userModel,
                                  qodDocRef: latestQodSnapshot!.reference,
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
