import 'package:attendance_app/domain/entities/attendance_entity.dart';
import 'package:attendance_app/domain/repositories/attendance_repository.dart';

class SubmitAttendanceUsecase {
  final AttendanceRepository _repository;

  SubmitAttendanceUsecase(this._repository);

  Future<void> checkin(AttendanceEntity attendance) async {
    await _repository.checkin(attendance);
  }

  Future<void> checkout(
    String attendanceId,
    double latitude,
    double longitude,
    DateTime checkoutTime,
    String status,
  ) async {
    await _repository.checkout(attendanceId, latitude, longitude, checkoutTime, status);
  }
}