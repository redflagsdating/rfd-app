import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/models/connection.dart';
import 'package:red_flags/models/qod.dart';
import 'package:red_flags/pages/profile/page_full_profile_view.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/animation/page_fade_route_builder.dart';
import 'package:red_flags/widgets/banner_user.dart';
import 'package:red_flags/widgets/cached_image.dart';
import 'package:red_flags/widgets/label/label_qod_status.dart';

class CardConnection extends StatefulWidget {
  const CardConnection({
    super.key,
    required this.qod,
    required this.connection,
  });

  final QodModel qod;
  final ConnectionModel connection;

  @override
  State<CardConnection> createState() => _CardUserProfileState();
}

class _CardUserProfileState extends State<CardConnection> {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final uid = widget.connection.uids
        .firstWhere((uid) => uid != userProvider.getIdCache());
    final qodBtnLabel = widget.qod.primaryUserAnswer == null
        ? l10n!.cardUserProfileAnswerBtn
        : l10n!.cardUserProfileViewResponseBtn;
    final qodRemainingTime = DateTime.now().difference(widget.qod.createdAt);

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 280,
        minHeight: 280,
        maxWidth: (MediaQuery.of(context).size.width * 0.8).ceil().toDouble(),
        maxHeight: (MediaQuery.of(context).size.height * 0.7).ceil().toDouble(),
      ),
      child: FutureBuilder(
        future: userProvider.getUserModelById(uid),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs;

          if (!snapshot.hasData || docs == null || docs.isEmpty) {
            return const SizedBox(
              height: 420,
              width: 300,
              child: Card(),
            );
          }

          final userModel = docs.first.data();

          return SingleChildScrollView(
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  PageFadeRouteBuilder(
                    page: Builder(
                      builder: (context) => PageFullProfileView(
                        userModel: userModel,
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
                          photoUrl: userModel.photoUrl,
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
                            userModel: userModel,
                            compact: true,
                          ),
                        )
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.qod.question,
                            maxLines: 3,
                            style: theme.textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          LabelQodStatus(qod: widget.qod),
                          const SizedBox(height: 8),
                          // TODO: Add condition of unlock "Go on a date" CTA
                          widget.qod.secondaryUserAnswer == null
                              ? Semantics(
                                  label: qodBtnLabel,
                                  child: FilledButton(
                                    onPressed: () async {
                                      // TODO: Example for later integration
                                      _scaffoldMessenger.showMaterialBanner(
                                        MaterialBanner(
                                          content: const Text(
                                              'Hello, I am a Material Banner'),
                                          leading: Icon(
                                            Icons.agriculture_outlined,
                                            color:
                                                theme.colorScheme.onSecondary,
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
                                      minimumSize: const Size.fromHeight(56),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8),
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          qodBtnLabel,
                                          style: theme.textTheme
                                              .apply(
                                                fontSizeFactor: 1.1,
                                                bodyColor:
                                                    theme.colorScheme.onPrimary,
                                              )
                                              .labelLarge,
                                        ),
                                        Text(
                                          l10n.cardUserProfileAnswerBtnNote(
                                            qodRemainingTime.inHours,
                                          ),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.w300,
                                            color: theme.colorScheme.onPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Semantics(
                                      label:
                                          l10n.cardUserProfileViewResponseBtn,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          // TODO
                                        },
                                        style: FilledButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                          ),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(8),
                                            ),
                                          ),
                                        ),
                                        child: Text(l10n
                                            .cardUserProfileViewResponseBtn),
                                      ),
                                    ),
                                    Semantics(
                                      label: l10n.btnGoOnDate,
                                      child: FilledButton(
                                        onPressed: () {
                                          // TODO
                                        },
                                        style: FilledButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                          ),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(8),
                                            ),
                                          ),
                                        ),
                                        child: Text(l10n.btnGoOnDate),
                                      ),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
