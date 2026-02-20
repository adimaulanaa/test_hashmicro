import 'package:attendance_app/domain/entities/attendance_history_entity.dart';
import 'package:attendance_app/domain/repositories/attendance_repository.dart';

class GetAttendanceHistoryUsecase {
  final AttendanceRepository _repository;

  GetAttendanceHistoryUsecase(this._repository);

  Future<List<AttendanceHistoryEntity>> call() async {
    return await _repository.getAttendanceHistories();
  }
}