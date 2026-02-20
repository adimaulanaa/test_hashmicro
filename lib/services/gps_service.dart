import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class GpsService {
  Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location service tidak aktif, mohon aktifkan GPS');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Izin lokasi ditolak permanen, mohon aktifkan di pengaturan',
      );
    }

    Position position;

    if (defaultTargetPlatform == TargetPlatform.android) {
      position = await Geolocator.getCurrentPosition(
        locationSettings: AndroidSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      position = await Geolocator.getCurrentPosition(
        locationSettings: AppleSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } else {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    }

    return position;
  }
}