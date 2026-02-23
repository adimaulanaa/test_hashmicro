import 'package:attendance_app/domain/entities/attendance_entity.dart';
import 'package:attendance_app/domain/entities/attendance_history_entity.dart';

abstract class AttendanceRepository {
  Future<List<AttendanceEntity>> getAttendances();
  Future<AttendanceEntity?> getTodayAttendance(String locationId);
  Future<void> checkin(AttendanceEntity attendance);
  Future<void> checkout(
    String attendanceId,
    double latitude,
    double longitude,
    DateTime checkoutTime,
    String status,
  );
  Future<List<AttendanceHistoryEntity>> getAttendanceHistories();
  Future<void> insertRejectedHistory({
    required String locationId,
    required double latitude,
    required double longitude,
    required String type,
  });
}
