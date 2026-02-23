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
  }) : _submitAttendanceUsecase = submitAttendanceUsecase,
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
      final todayAttendance = await _attendanceRepository.getTodayAttendance(
        event.locationId,
      );
      emit(
        AttendanceLoaded(
          attendances: attendances,
          todayAttendance: todayAttendance,
        ),
      );
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

      if (!isValid) {
        // hanya simpan ke history, tidak ke attendances
        await _attendanceRepository.insertRejectedHistory(
          locationId: event.locationId,
          latitude: position.latitude,
          longitude: position.longitude,
          type: 'checkin',
        );
        emit(
          AttendanceRejected(
            'Checkin ditolak, kamu berada di luar radius 50 meter',
          ),
        );
        return;
      }

      final attendance = AttendanceEntity(
        id: const Uuid().v4(),
        locationId: event.locationId,
        checkinLatitude: position.latitude,
        checkinLongitude: position.longitude,
        checkinTime: DateTime.now(),
        checkinStatus: 'approved',
        createdAt: DateTime.now(),
      );

      await _submitAttendanceUsecase.checkin(attendance);
      emit(AttendanceSuccess('Checkin berhasil'));
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

      if (!isValid) {
        // hanya simpan ke history, tidak update attendances
        await _attendanceRepository.insertRejectedHistory(
          locationId: event.locationId,
          latitude: position.latitude,
          longitude: position.longitude,
          type: 'checkout',
        );
        emit(
          AttendanceRejected(
            'Checkout ditolak, kamu berada di luar radius 50 meter',
          ),
        );
        return;
      }

      await _submitAttendanceUsecase.checkout(
        event.attendanceId,
        position.latitude,
        position.longitude,
        DateTime.now(),
        'approved',
      );
      emit(AttendanceSuccess('Checkout berhasil'));
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }
}
