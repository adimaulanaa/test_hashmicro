import 'package:attendance_app/domain/entities/location_entity.dart';

abstract class LocationRepository {
  Future<List<LocationEntity>> getLocations();
  Future<void> addLocation(LocationEntity location);
  Future<void> deleteLocation(String id);
}