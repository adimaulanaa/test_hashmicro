import 'dart:math';

class DistanceHelper {
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0; // dalam meter

    final dLat = _toRadian(lat2 - lat1);
    final dLon = _toRadian(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadian(lat1)) *
            cos(_toRadian(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadian(double degree) {
    return degree * pi / 180;
  }
}