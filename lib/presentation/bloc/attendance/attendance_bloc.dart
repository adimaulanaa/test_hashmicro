import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/attendance_entity.dart';
import '../../../domain/usecases/attendance/get_attendance_history_usecase.dart';
import '../../../domain/usecases/attendance/submit_attendance_usecase.dart';
import '../../../domain/usecases/attendance/validate_radius_usecase.dart';
import '../../../domain/repositories/attendance_repository.dart';
import '../../../services/gps_service.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final SubmitAttendanceUsecase _submitAttendanceUsecase;
  final ValidateRadiusUsecase _validateRadiusUsecase;
  final GetAttendanceHistoryUsecase _getAttendanceHistoryUsecase;
  final AttendanceRepository _attendanceRepository;
  final GpsService _gpsService;

  AttendanceBloc({
    required SubmitAttendanceUsecase submitAttendanceUsecase,
    required ValidateRadiusUsecase validateRadiusUsecase,
    required GetAttendanceHistoryUsecase getAttendanceHistoryUsecase,
    required AttendanceRepository attendanceRepository,
    required GpsService gpsService,
  })  : _submitAttendanceUsecase = submitAttendanceUsecase,
        _validateRadiusUsecase = validateRadiusUsecase,
        _getAttendanceHistoryUsecase = getAttendanceHistoryUsecase,
        _attendanceRepository = attendanceRepository,
        _gpsService = gpsService,
        super(AttendanceInitial()) {
    on<GetAttendancesEvent>(_onGetAttendances);
    on<GetAttendanceHistoriesEvent>(_onGetAttendanceHistories);
    on<CheckinEvent>(_onCheckin);
    on<CheckoutEvent>(_onCheckout);
  }

  Future<void> _onGetAttendances(
    GetAttendancesEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final attendances = await _attendanceRepository.getAttendances();
      emit(AttendanceLoaded(attendances: attendances));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> _onGetAttendanceHistories(
    GetAttendanceHistoriesEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final histories = await _getAttendanceHistoryUsecase();
      emit(AttendanceHistoryLoaded(histories));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> _onCheckin(
    CheckinEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final position = await _gpsService.getCurrentPosition();

      final isValid = _validateRadiusUsecase(
        userLatitude: position.latitude,
        userLongitude: position.longitude,
        locationLatitude: event.locationLatitude,
        locationLongitude: event.locationLongitude,
      );

      final status = isValid ? 'approved' : 'rejected';

      final attendance = AttendanceEntity(
        id: const Uuid().v4(),
        locationId: event.locationId,
        checkinLatitude: position.latitude,
        checkinLongitude: position.longitude,
        checkinTime: DateTime.now(),
        checkinStatus: status,
        createdAt: DateTime.now(),
      );

      await _submitAttendanceUsecase.checkin(attendance);

      if (isValid) {
        emit(AttendanceSuccess('Checkin berhasil'));
      } else {
        emit(AttendanceRejected('Checkin ditolak, kamu berada di luar radius 50 meter'));
      }
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> _onCheckout(
    CheckoutEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    try {
      final position = await _gpsService.getCurrentPosition();

      final isValid = _validateRadiusUsecase(
        userLatitude: position.latitude,
        userLongitude: position.longitude,
        locationLatitude: event.locationLatitude,
        locationLongitude: event.locationLongitude,
      );

      final status = isValid ? 'approved' : 'rejected';

      await _submitAttendanceUsecase.checkout(
        event.attendanceId,
        position.latitude,
        position.longitude,
        DateTime.now(),
        status,
      );

      if (isValid) {
        emit(AttendanceSuccess('Checkout berhasil'));
      } else {
        emit(AttendanceRejected('Checkout ditolak, kamu berada di luar radius 50 meter'));
      }
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }
}