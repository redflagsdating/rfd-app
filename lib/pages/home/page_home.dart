import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/pages/profile/page_profile_settings_kyc.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/card/card_connection.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  late ScaffoldMessengerState _scaffoldMessenger;

  @override
  void initState() {
    Future.delayed(
      const Duration(milliseconds: 300),
      () {
        final theme = Theme.of(context);
        final l10n = AppLocalizations.of(context);
        final isSubmitted =
            context.read<UserProvider>().getVerifySubmittedCache();

        _scaffoldMessenger = ScaffoldMessenger.of(context);

        if (isSubmitted != true) {
          _scaffoldMessenger.showMaterialBanner(
            MaterialBanner(
              content: const Text(
                'You are creating the worlds safest dating community. Verify your account now.',
              ),
              leading: Icon(
                Icons.verified_rounded,
                color: theme.colorScheme.onSecondary,
              ),
              actions: [
                FilledButton.tonal(
                  onPressed: () async {
                    _scaffoldMessenger.clearMaterialBanners();

                    await Future.delayed(const Duration(milliseconds: 300));

                    // ignore: use_build_context_synchronously
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PageProfileSettingsKyc(
                          title: Text(
                            l10n!.verification,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Verify'),
                ),
              ],
            ),
          );
        }
      },
    );
    super.initState();
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
    final connections = userProvider.getConnectionsCache();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      color: theme.colorScheme.inversePrimary.withOpacity(0.2),
      alignment: Alignment.center,
      child: RefreshIndicator(
        onRefresh: () async {
          // Refetch current logged in userModel
          // final userModel = await userProvider.getUserModel();

          // if (userModel != null) {
          //   // Update cache in SharedPreference
          //   await userProvider.updateUserCache(userModel);
          //   final connections = userModel.connections;

          //   // Below fetches are mainly for CardConnection to update cache
          //   if (connections != null) {
          //     await Future.wait(
          //       connections.map((id) async {
          //         // Refetch DocumentSnapshot of the connection document
          //         final snapshot = await connectionRef.doc(id).get();

          //         // Find the connection uid
          //         final uid = snapshot
          //             .data()
          //             ?.uids
          //             .firstWhere((uid) => uid != userModel.uid);

          //         /// Refetch connected with userModel
          //         if (uid != null) {
          //           await userProvider.getUserModelById(uid);
          //         }

          //         /// Refetch the latest QoD of the connection document
          //         final qodSnapshot = await qodRef(id)
          //             .orderBy(
          //               QodFields.createdAt.name,
          //               descending: true,
          //             )
          //             .get();

          //         // Refetch qodAnswer documents of the latest QoD
          //         await qodAnswerRef(
          //                 qodRef(id).doc(qodSnapshot.docs.firstOrNull?.id))
          //             .get();
          //       }),
          //     );
          //   }
          // }

          // setState(() {});
        },
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: connections.isEmpty
                      ? [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: Text(
                              // l10n!.pgHomeEmpty,
                              // TODO: Temporary for marketing
                              "Coming soon!",
                              textAlign: TextAlign.center,
                              style: theme.textTheme
                                  .apply(bodyColor: theme.colorScheme.secondary)
                                  .titleLarge,
                            ),
                          ),
                          SvgPicture.asset(
                            "assets/rfi-daily-profile-transparent.svg",
                            height: MediaQuery.of(context).size.width,
                            semanticsLabel: l10n!.pgHomeEmpty,
                          ),
                        ]
                      : [
                          Text(
                            l10n!.pgHomeTitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme
                                .apply(bodyColor: theme.colorScheme.secondary)
                                .titleMedium,
                          ),
                          const SizedBox(height: 24),
                          CarouselSlider(
                            options: CarouselOptions(
                              initialPage: 1,
                              enlargeFactor: 0.4,
                              enlargeCenterPage: true,
                              enableInfiniteScroll: false,
                              enlargeStrategy: CenterPageEnlargeStrategy.zoom,
                              height: 480,
                            ),
                            items: List.generate(
                              connections.length,
                              (index) {
                                return CardConnection(id: connections[index]);
                              },
                            ),
                          ),
                        ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
