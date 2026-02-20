abstract class LocationEvent {}

class GetLocationsEvent extends LocationEvent {}

class AddLocationEvent extends LocationEvent {
  final String name;
  final double latitude;
  final double longitude;

  AddLocationEvent({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

class DeleteLocationEvent extends LocationEvent {
  final String id;

  DeleteLocationEvent(this.id);
}