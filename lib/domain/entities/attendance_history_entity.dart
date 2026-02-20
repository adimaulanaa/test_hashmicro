class AttendanceHistoryEntity {
  final String id;
  final String attendanceId;
  final String locationId;
  final double latitude;
  final double longitude;
  final String type;
  final String status;
  final DateTime createdAt;

  const AttendanceHistoryEntity({
    required this.id,
    required this.attendanceId,
    required this.locationId,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.status,
    required this.createdAt,
  });
}