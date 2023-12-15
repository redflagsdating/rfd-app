import 'package:geolocator/geolocator.dart';

enum GeolocatorError {
  disabled,
  rejected,
  denied,
}

mixin MixinPermissions {
  // Request permissions to use device location services
  Future<bool> requestLocationPermissions() async {
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
}
