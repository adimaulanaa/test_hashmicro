import 'package:attendance_app/core/constants/app_constants.dart';
import 'package:attendance_app/core/utils/distance_helper.dart';

class ValidateRadiusUsecase {
  bool call({
    required double userLatitude,
    required double userLongitude,
    required double locationLatitude,
    required double locationLongitude,
  }) {
    final distance = DistanceHelper.calculateDistance(
      userLatitude,
      userLongitude,
      locationLatitude,
      locationLongitude,
    );
    return distance <= AppConstants.maxRadiusInMeters;
  }
}