import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/mixins/mixin_permissions.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/services/logger_provider.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/badge_kyc_status.dart';

class BannerUser extends StatefulWidget {
  const BannerUser({
    super.key,
    required this.userModel,
    this.compact,
    this.answerCount,
    this.messageCount,
  });
  final UserModel userModel;
  final bool? compact;
  final int? answerCount;
  final int? messageCount;

  @override
  State<BannerUser> createState() => _BannerUserState();
}

class _BannerUserState extends State<BannerUser> with MixinPermissions {
  // Calculates the distance between user current position and profile locality
  // in km.
  Future<double> _getDistance() async {
    final logger = context.read<LoggerProvider>().logger;

    // Skip Geolocator logic when in test mode
    if (!Platform.environment.containsKey("FLUTTER_TEST")) {
      try {
        await requestLocationPermissions();

        final current = await Geolocator.getCurrentPosition();
        final locality = widget.userModel.locality;

        if (locality != null) {
          final location = await locationFromAddress(
            locality,
            localeIdentifier: Platform.localeName,
          );
          final meters = Geolocator.distanceBetween(
            location.first.latitude,
            location.first.longitude,
            current.latitude,
            current.longitude,
          );

          if (meters > 0) {
            return (meters / 1000).roundToDouble();
          }
        }
      } catch (e) {
        logger.e(e, time: DateTime.now());
      }
    }

    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final userProvider = context.read<UserProvider>();
    final textWhiteTheme = theme.textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    );

    final dob = widget.userModel.dob;
    final displayName = widget.userModel.displayName;
    final firstName = widget.userModel.firstName;
    final lastName = widget.userModel.lastName;
    final isCompact = widget.compact == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '${displayName ?? '$firstName $lastName'},',
                  style: isCompact
                      ? textWhiteTheme.titleLarge
                      : textWhiteTheme.headlineMedium,
                ),
                const SizedBox(width: 6),
                BadgeKycStatus(
                  offset: const Offset(0, 0),
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: isCompact ? 60 : 70,
                    child: Text(
                      dob != null ? userProvider.getAge(dob).toString() : "-",
                      style: isCompact
                          ? textWhiteTheme.titleLarge
                          : textWhiteTheme.headlineMedium,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                widget.answerCount != null
                    ? Chip(
                        padding: const EdgeInsets.all(4),
                        labelPadding: const EdgeInsets.only(right: 4),
                        label: Text(
                          widget.answerCount.toString(),
                          style: textWhiteTheme.labelMedium,
                        ),
                        avatar: const Icon(
                          FontAwesomeIcons.fireFlameCurved,
                          color: Colors.white,
                          size: 14,
                        ),
                        visualDensity: VisualDensity.compact,
                        side: MaterialStateBorderSide.resolveWith((states) {
                          return const BorderSide(color: Colors.transparent);
                        }),
                        color: MaterialStateProperty.resolveWith(
                          (states) {
                            return theme.colorScheme.tertiary;
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
                const SizedBox(width: 8),
                widget.messageCount != null
                    ? Chip(
                        padding: const EdgeInsets.all(4),
                        labelPadding: const EdgeInsets.only(right: 4),
                        label: Text(
                          widget.messageCount.toString(),
                          style: textWhiteTheme.labelMedium,
                        ),
                        avatar: const Icon(
                          FontAwesomeIcons.solidComment,
                          color: Colors.white,
                          size: 14,
                        ),
                        visualDensity: VisualDensity.compact,
                        side: MaterialStateBorderSide.resolveWith((states) {
                          return const BorderSide(color: Colors.transparent);
                        }),
                        color: MaterialStateProperty.resolveWith(
                          (states) {
                            return theme.colorScheme.inversePrimary;
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_rounded,
              size: isCompact ? 18 : 20,
              color: Colors.white,
            ),
            const SizedBox(width: 2),
            FutureBuilder(
              future: _getDistance(),
              builder: (context, snapshot) {
                final distance = snapshot.data;

                return Text.rich(
                  style: isCompact
                      ? textWhiteTheme.bodySmall
                      : textWhiteTheme.bodyMedium,
                  TextSpan(
                    children: [
                      distance == null
                          ? WidgetSpan(
                              child: LoadingAnimationWidget.prograssiveDots(
                                color: theme.colorScheme.surfaceVariant,
                                size: isCompact ? 16 : 20,
                              ),
                            )
                          : TextSpan(text: snapshot.data.toString()),
                      const TextSpan(text: ' '),
                      TextSpan(text: l10n!.kilometer)
                    ],
                  ),
                );
              },
            ),
            SizedBox(width: isCompact ? 10 : 16),
            Icon(
              Icons.home,
              color: Colors.white,
              size: isCompact ? 18 : 20,
            ),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                widget.userModel.locality ?? '-',
                style: isCompact
                    ? textWhiteTheme.bodySmall
                    : textWhiteTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
