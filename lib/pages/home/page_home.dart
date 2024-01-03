import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/card_user_profile.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      color: theme.colorScheme.inversePrimary.withOpacity(0.2),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n!.pgHomeTitle,
              style: theme.textTheme
                  .apply(bodyColor: theme.colorScheme.secondary)
                  .titleMedium,
            ),
            const SizedBox(height: 24),
            CarouselSlider(
              options: CarouselOptions(
                enlargeFactor: 0.4,
                enlargeCenterPage: true,
                enlargeStrategy: CenterPageEnlargeStrategy.zoom,
                height: 520,
              ),
              items: List.generate(
                3,
                (index) {
                  // TODO: Change to actual matches or placeholder
                  return CardUserProfile(
                    userModel: userProvider.getUserCache(),
                    question:
                        "What is something about you that surprises most people?",
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
