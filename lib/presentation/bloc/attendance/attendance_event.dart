abstract class AttendanceEvent {}

class GetAttendancesEvent extends AttendanceEvent {}

class GetAttendanceHistoriesEvent extends AttendanceEvent {}

class CheckinEvent extends AttendanceEvent {
  final String locationId;
  final double locationLatitude;
  final double locationLongitude;

  CheckinEvent({
    required this.locationId,
    required this.locationLatitude,
    required this.locationLongitude,
  });
}

class CheckoutEvent extends AttendanceEvent {
  final String attendanceId;
  final String locationId;
  final double locationLatitude;
  final double locationLongitude;

  CheckoutEvent({
    required this.attendanceId,
    required this.locationId,
    required this.locationLatitude,
    required this.locationLongitude,
  });
}