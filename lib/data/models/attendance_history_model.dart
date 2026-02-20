import 'package:attendance_app/domain/entities/attendance_history_entity.dart';

class AttendanceHistoryModel extends AttendanceHistoryEntity {
  const AttendanceHistoryModel({
    required super.id,
    required super.attendanceId,
    required super.locationId,
    required super.latitude,
    required super.longitude,
    required super.type,
    required super.status,
    required super.createdAt,
  });

  factory AttendanceHistoryModel.fromMap(Map<String, dynamic> map) {
    return AttendanceHistoryModel(
      id: map['id'],
      attendanceId: map['attendance_id'],
      locationId: map['location_id'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      type: map['type'],
      status: map['status'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'attendance_id': attendanceId,
      'location_id': locationId,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}