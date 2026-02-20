class AttendanceEntity {
  final String id;
  final String locationId;
  final double? checkinLatitude;
  final double? checkinLongitude;
  final DateTime? checkinTime;
  final String? checkinStatus;
  final double? checkoutLatitude;
  final double? checkoutLongitude;
  final DateTime? checkoutTime;
  final String? checkoutStatus;
  final DateTime createdAt;

  const AttendanceEntity({
    required this.id,
    required this.locationId,
    this.checkinLatitude,
    this.checkinLongitude,
    this.checkinTime,
    this.checkinStatus,
    this.checkoutLatitude,
    this.checkoutLongitude,
    this.checkoutTime,
    this.checkoutStatus,
    required this.createdAt,
  });
}