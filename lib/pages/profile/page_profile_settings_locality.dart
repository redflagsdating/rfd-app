import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/user_provider.dart';
import 'package:red_flags/widgets/profile/profile_locality.dart';
import 'package:red_flags/widgets/scaffold_page_basic.dart';

class PageProfileSettingsLocality extends StatefulWidget {
  const PageProfileSettingsLocality({super.key, this.title});
  final Widget? title;

  @override
  State<PageProfileSettingsLocality> createState() =>
      _PageProfileSettingsLocalityState();
}

class _PageProfileSettingsLocalityState
    extends State<PageProfileSettingsLocality> {
  bool _enabled = true;
  List<double>? _coordinates;
  final _form = GlobalKey<FormState>();
  final _controller = TextEditingController();
  late ScaffoldMessengerState _scaffoldMessenger;

  void _setEnabled(bool value) {
    setState(() {
      _enabled = value;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scaffoldMessenger.clearSnackBars();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _scaffoldMessenger = ScaffoldMessenger.of(context);
    _controller.text = Provider.of<UserProvider>(context).getLocalityCache();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userProvider = context.read<UserProvider>();

    return ScaffoldPageBasic(
      title: widget.title,
      actions: [
        Semantics(
          button: true,
          label: '${l10n!.save} ${widget.title}',
          child: TextButton(
            child: Text(l10n.save),
            onPressed: () async {
              if (!_form.currentState!.validate()) {
                return;
              }

              final current = userProvider.getLocalityCache();
              final locality = _controller.text;

              if (current == locality) {
                return;
              }

              _setEnabled(false);

              final results = await Future.wait([
                userProvider.setLocality(
                  locality,
                  localOnly: false,
                ),
                _coordinates != null
                    ? userProvider.setLatlng(
                        _coordinates!,
                        localOnly: false,
                      )
                    : Future.value(true),
              ]);

              _scaffoldMessenger.showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 2),
                  content: Text(results.every((result) => result == true)
                      ? l10n.pgProfileSuccessfulUpdated
                      : l10n.pgProfileFailedUpdated),
                ),
              );

              _setEnabled(true);
            },
          ),
        ),
      ],
      content: Form(
        key: _form,
        child: ProfileLocality(
          enabled: _enabled,
          controller: _controller,
          onChangeCoordinates: (values) => _coordinates = values,
        ),
      ),
      onBackPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
}
