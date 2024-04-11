import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/mixins/mixin_api.dart';
import 'package:red_flags/models/connection.dart';
import 'package:red_flags/models/qod.dart';
import 'package:red_flags/models/qod_answer.dart';
import 'package:red_flags/services/logger_provider.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/card/card_connection.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> with MixinApi {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final logger = context.read<LoggerProvider>().logger;
    final userProvider = Provider.of<UserProvider>(context);
    final connections = userProvider.getConnectionsCache();
    final isVerified = userProvider.getVerifiedCache() == true;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      color: theme.colorScheme.inversePrimary.withOpacity(0.2),
      alignment: Alignment.center,
      child: RefreshIndicator(
        onRefresh: () async {
          // Search new connections
          if (isVerified && connections.length < 3) {
            try {
              await addUserNewConnections();
            } catch (error) {
              logger.e(error, time: DateTime.now());
            }
          }

          // Refetch current logged in userModel
          final userModel = await userProvider.getUserModel();

          if (userModel != null) {
            // Update cache in SharedPreference
            await userProvider.updateUserCache(userModel);
            final latestConnections = userModel.connections;

            // Below fetches are mainly for CardConnection to update cache
            if (latestConnections != null) {
              await Future.wait(
                latestConnections.map((connectionId) async {
                  // Refetch DocumentSnapshot of the connection document
                  final snapshot = await connectionRef.doc(connectionId).get();

                  // Find the connection uid
                  final uid = snapshot
                      .data()
                      ?.uids
                      .firstWhere((uid) => uid != userModel.uid);

                  /// Refetch connected with userModel
                  if (uid != null) {
                    await userProvider.getUserModelById(uid);
                  }

                  /// Refetch the latest QoD of the connection document
                  final qodSnapshot = await qodRef(connectionId)
                      .orderBy(
                        QodFields.createdAt.name,
                        descending: true,
                      )
                      .get();

                  // Refetch qodAnswer documents of the latest QoD
                  await qodAnswerRef(qodRef(connectionId)
                          .doc(qodSnapshot.docs.firstOrNull?.id))
                      .get();
                }),
              );
            }
          }

          setState(() {});
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
                              isVerified
                                  ? l10n!.pgHomeVerifiedEmpty
                                  : l10n!.pgHomeNotVerifiedEmpty,
                              textAlign: TextAlign.center,
                              style: theme.textTheme
                                  .apply(bodyColor: theme.colorScheme.secondary)
                                  .titleLarge,
                            ),
                          ),
                          SvgPicture.asset(
                            "assets/rfi-daily-profile-transparent.svg",
                            height: MediaQuery.of(context).size.width,
                            semanticsLabel: isVerified
                                ? l10n.pgHomeVerifiedEmpty
                                : l10n.pgHomeNotVerifiedEmpty,
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
