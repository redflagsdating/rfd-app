import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/mixins/mixin_permissions.dart';
import 'package:red_flags/models/user.dart';
import 'package:red_flags/services/logger_provider.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/user_kyc_badge.dart';

class UserProfileBanner extends StatefulWidget {
  const UserProfileBanner({super.key, required this.userModel});
  final UserModel userModel;

  @override
  State<UserProfileBanner> createState() => _UserProfileBannerState();
}

class _UserProfileBannerState extends State<UserProfileBanner>
    with MixinPermissions {
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

    final dob = widget.userModel.dob;
    final displayName = widget.userModel.displayName;
    final firstName = widget.userModel.firstName;
    final lastName = widget.userModel.lastName;
    // Split to cater long location string and prevent overflow
    final locality = (widget.userModel.locality ?? '-').split(',');

    return Column(
      children: [
        Row(
          children: [
            Text(
              '${displayName ?? '$firstName $lastName'},',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(width: 6),
            UserKycBadge(
              offset: const Offset(0, 0),
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 70,
                child: Text(
                  dob != null ? userProvider.getAge(dob).toString() : "-",
                  style: theme.textTheme.headlineMedium,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.location_on_rounded),
            const SizedBox(width: 2),
            FutureBuilder(
              future: _getDistance(),
              builder: (context, snapshot) {
                final distance = snapshot.data;

                return Text.rich(
                  TextSpan(
                    children: [
                      distance == null
                          ? WidgetSpan(
                              child:
                                  LoadingAnimationWidget.horizontalRotatingDots(
                                color: theme.colorScheme.outlineVariant,
                                size: 20,
                              ),
                            )
                          : TextSpan(
                              text: distance.toString(),
                            ),
                      const TextSpan(text: ' '),
                      TextSpan(text: l10n!.kilometer)
                    ],
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            const Icon(Icons.home),
            const SizedBox(width: 2),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                locality.length,
                (index) => Text(
                  locality[index].trim(),
                  textHeightBehavior: const TextHeightBehavior(
                    applyHeightToFirstAscent: false,
                    applyHeightToLastDescent: false,
                    leadingDistribution: TextLeadingDistribution.even,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
