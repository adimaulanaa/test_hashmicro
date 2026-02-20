import '../../../domain/entities/location_entity.dart';

abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationLoaded extends LocationState {
  final List<LocationEntity> locations;

  LocationLoaded(this.locations);
}

class LocationError extends LocationState {
  final String message;

  LocationError(this.message);
}