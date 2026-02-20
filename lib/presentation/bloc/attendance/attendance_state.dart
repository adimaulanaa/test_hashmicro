import '../../../domain/entities/attendance_entity.dart';
import '../../../domain/entities/attendance_history_entity.dart';

abstract class AttendanceState {}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final List<AttendanceEntity> attendances;
  final AttendanceEntity? todayAttendance;

  AttendanceLoaded({
    required this.attendances,
    this.todayAttendance,
  });
}

class AttendanceHistoryLoaded extends AttendanceState {
  final List<AttendanceHistoryEntity> histories;

  AttendanceHistoryLoaded(this.histories);
}

class AttendanceSuccess extends AttendanceState {
  final String message;

  AttendanceSuccess(this.message);
}

class AttendanceRejected extends AttendanceState {
  final String message;

  AttendanceRejected(this.message);
}

class AttendanceError extends AttendanceState {
  final String message;

  AttendanceError(this.message);
}