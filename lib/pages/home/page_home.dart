import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
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
              options: CarouselOptions(height: 420),
              items: List.generate(
                3,
                (index) {
                  return const SizedBox(
                    width: 300,
                    child: Card(
                        // child: Column(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     TextButton(
                        //       onPressed: () {
                        //         _scaffoldMessenger.showMaterialBanner(
                        //           MaterialBanner(
                        //             content: const Text(
                        //                 'Hello, I am a Material Banner'),
                        //             leading: Icon(
                        //               Icons.agriculture_outlined,
                        //               color: theme.colorScheme.onSecondary,
                        //             ),
                        //             actions: [
                        //               TextButton(
                        //                 onPressed: () {
                        //                   ScaffoldMessenger.of(context)
                        //                       .hideCurrentMaterialBanner();
                        //                 },
                        //                 child: Text('DISMISS'),
                        //               ),
                        //             ],
                        //           ),
                        //         );
                        //       },
                        //       child: Text('Show Banner'),
                        //     ),
                        //   ],
                        // ),
                        ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
