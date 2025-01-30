import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Stream<String> getPlaceName() async* {
    String? lastPlace; // Store the last known place name

    while (true) {
      try {
        print('Fetching location...');

        // Get the current position
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);

        // Get place name from coordinates
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        String placeName = placemarks.first.locality ?? "Unknown";

        // Emit only if the place name has changed
        if (placeName != lastPlace) {
          lastPlace = placeName;
          yield placeName; // Update the stream
        }
      } catch (e) {
        yield 'Not available';
      }

      await Future.delayed(const Duration(seconds: 5));
    }
  }

  Stream<double> calculateDistance(
      double endLatitude, double endLongitude) async* {
    while (true) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        endLatitude,
        endLongitude,
      );

      double distanceInKm = distanceInMeters / 1000;
      double formattedDistance = double.parse(distanceInKm.toStringAsFixed(2));

      yield formattedDistance;

      await Future.delayed(const Duration(seconds: 2));
    }
  }
}
