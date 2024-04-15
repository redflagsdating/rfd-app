import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/mixins/mixin_api.dart';
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

    return StreamBuilder(
      stream: userProvider.userDocRef!.snapshots(),
      builder: (context, snapshot) {
        final userModel = snapshot.data?.data();
        final connections = userModel?.connections ?? [];
        final isVerified = userModel?.verified == true;

        if (userModel != null) {
          // Non-blocking update cache in SharedPreference
          userProvider.updateUserCache(userModel);
        }

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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 28),
                                child: Text(
                                  isVerified
                                      ? l10n!.pgHomeVerifiedEmpty
                                      : l10n!.pgHomeNotVerifiedEmpty,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme
                                      .apply(
                                          bodyColor:
                                              theme.colorScheme.secondary)
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
                                    .apply(
                                        bodyColor: theme.colorScheme.secondary)
                                    .titleMedium,
                              ),
                              const SizedBox(height: 24),
                              CarouselSlider(
                                options: CarouselOptions(
                                  initialPage: 1,
                                  enlargeFactor: 0.4,
                                  enlargeCenterPage: true,
                                  enableInfiniteScroll: false,
                                  enlargeStrategy:
                                      CenterPageEnlargeStrategy.zoom,
                                  height: 480,
                                ),
                                items: List.generate(
                                  connections.length,
                                  (index) {
                                    return CardConnection(
                                      id: connections[index],
                                    );
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
      },
    );
  }
}
