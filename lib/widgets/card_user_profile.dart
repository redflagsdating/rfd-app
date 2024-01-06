import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/pages/profile/page_full_profile_view.dart';
import 'package:red_flags/widgets/animation/page_fade_route_builder.dart';
import 'package:red_flags/widgets/banner_user.dart';
import 'package:red_flags/widgets/cached_image.dart';

class CardUserProfile extends StatefulWidget {
  const CardUserProfile({
    super.key,
    required this.userModel,
    required this.question,
  });
  final UserModel userModel;
  final String question;

  @override
  State<CardUserProfile> createState() => _CardUserProfileState();
}

class _CardUserProfileState extends State<CardUserProfile> {
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

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 280,
        minHeight: 280,
        maxWidth: (MediaQuery.of(context).size.width * 0.8).ceil().toDouble(),
        maxHeight: (MediaQuery.of(context).size.height * 0.7).ceil().toDouble(),
      ),
      child: SingleChildScrollView(
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              PageFadeRouteBuilder(
                page: Builder(
                  builder: (context) => PageFullProfileView(
                    userModel: widget.userModel,
                  ),
                ),
              ),
            );
          },
          child: Card(
            clipBehavior: Clip.hardEdge,
            surfaceTintColor: theme.colorScheme.background,
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
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.question,
                        maxLines: 3,
                        style: theme.textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        // TODO: QoD status
                        l10n!.cardUserProfileNoAnswerNote,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // TODO: Change to question anwser status
                      widget.question.length > 1
                          ? Semantics(
                              // TODO: Dynamic label base on condition
                              label: l10n.cardUserProfileAnswerBtn,
                              child: FilledButton(
                                onPressed: () {
                                  // TODO
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
                                      // TODO: Add condition to show different labels
                                      l10n.cardUserProfileAnswerBtn,
                                      style: theme.textTheme
                                          .apply(
                                            fontSizeFactor: 1.1,
                                            bodyColor:
                                                theme.colorScheme.onPrimary,
                                          )
                                          .labelLarge,
                                    ),
                                    Text(
                                      // TODO: Change to QoD hours left
                                      l10n.cardUserProfileAnswerBtnNote(4),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Semantics(
                                  label: l10n.cardUserProfileViewResponseBtn,
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
                                    child: Text(
                                        l10n.cardUserProfileViewResponseBtn),
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
      ),
    );
  }
}
