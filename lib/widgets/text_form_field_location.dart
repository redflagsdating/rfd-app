import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:red_flags/services/logger_provider.dart';

enum GeolocatorError {
  disabled,
  rejected,
  denied,
}

class TextFormFieldLocation extends StatefulWidget {
  const TextFormFieldLocation({
    super.key,
    this.enabled,
    required this.controller,
  });

  final bool? enabled;
  final TextEditingController controller;

  @override
  State<TextFormFieldLocation> createState() => _TextFormFieldLocationState();
}

class _TextFormFieldLocationState extends State<TextFormFieldLocation> {
  bool _loading = false;
  Position? _pos;
  Timer? _throttle;
  String? _errorText;

  final _location = FocusNode();

  void setLoading(bool value) {
    setState(() {
      _loading = value;
    });
  }

  Future<void> _reverseGeocoding() async {
    if (_pos == null) {
      return;
    }

    try {
      setLoading(true);

      final placemarks =
          await placemarkFromCoordinates(_pos!.latitude, _pos!.longitude);

      if (placemarks.isNotEmpty) {
        final place = [
          placemarks.first.locality,
          placemarks.first.administrativeArea
        ];

        widget.controller.text = place.join(', ');
      }
    } catch (e) {
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  // Use mobile phone GPS to get current coordinates
  Future<bool> _requestLocationPermissions() async {
    LocationPermission permission;

    if (!await Geolocator.isLocationServiceEnabled()) {
      return Future.error(GeolocatorError.disabled);
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Attempt to request permissions when it is currently not allowed
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error(GeolocatorError.rejected);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(GeolocatorError.denied);
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final logger = Provider.of<LoggerProvider>(context).logger;

    Future<void> getCurrentLocation() async {
      try {
        await _requestLocationPermissions();

        setLoading(true);
        // ignore: use_build_context_synchronously
        FocusScope.of(context).requestFocus(_location);
        _pos = await Geolocator.getCurrentPosition();
      } catch (e) {
        rethrow;
      } finally {
        setLoading(false);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          autofocus: true,
          focusNode: _location,
          enabled: widget.enabled,
          controller: widget.controller,
          onChanged: (value) {
            if (value.isEmpty) {
              return;
            }

            if (_throttle != null) {
              _throttle?.cancel();
              _throttle = null;
            }

            _throttle = Timer(const Duration(milliseconds: 300), () async {
              setLoading(true);

              try {
                List<Location> locations = await locationFromAddress(value);

                _errorText = locations.isEmpty
                    ? l10n.fieldLocationResolvedErrorText
                    : null;
              } catch (e) {
                logger.d(e, time: DateTime.now());
                _errorText = l10n.fieldLocationResolvedErrorText;
              } finally {
                setLoading(false);
                _throttle = null;
              }
            });
          },
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            hintText: l10n!.fieldLocationHintText,
            errorMaxLines: 2,
            errorText: _errorText,
            suffix: Container(
              height: 20,
              width: 20,
              margin: const EdgeInsets.only(right: 10),
              child: _loading
                  ? const CircularProgressIndicator(
                      strokeWidth: 2,
                    )
                  : null,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.fieldLocationEmptyErrorText;
            }

            return null;
          },
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () async {
            if (_loading) {
              return;
            }

            _errorText = null;

            try {
              await getCurrentLocation();
            } catch (e) {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    e == GeolocatorError.disabled
                        ? l10n.fieldLocationDisabledError
                        : e == GeolocatorError.rejected
                            ? l10n.fieldLocationRejectedError
                            : e == GeolocatorError.denied
                                ? l10n.fieldLocationDeniedError(l10n.brandName)
                                : "",
                  ),
                  action: SnackBarAction(
                    label: e == GeolocatorError.rejected
                        ? l10n.allow
                        : l10n.settings,
                    onPressed: () async {
                      if (e == GeolocatorError.rejected) {
                        await getCurrentLocation();
                        await _reverseGeocoding();
                      } else {
                        AppSettings.openAppSettings(
                          type: AppSettingsType.location,
                        );
                      }
                    },
                  ),
                ),
              );
            }

            try {
              await _reverseGeocoding();
            } catch (e) {
              logger.e(e, time: DateTime.now());
            }
          },
          child: SizedBox(
            height: 40,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.my_location,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.fieldLocationUseCurrentBtn,
                  style: theme.textTheme
                      .apply(
                        bodyColor: theme.colorScheme.primary,
                      )
                      .labelLarge,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
