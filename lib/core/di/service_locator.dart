import 'package:attendance_app/data/datasources/local_database.dart';
import 'package:attendance_app/data/repositories/attendance_repository_impl.dart';
import 'package:attendance_app/data/repositories/location_repository_impl.dart';
import 'package:attendance_app/domain/usecases/attendance/get_attendance_history_usecase.dart';
import 'package:attendance_app/domain/usecases/attendance/submit_attendance_usecase.dart';
import 'package:attendance_app/domain/usecases/attendance/validate_radius_usecase.dart';
import 'package:attendance_app/domain/usecases/location/add_location_usecase.dart';
import 'package:attendance_app/domain/usecases/location/delete_location_usecase.dart';
import 'package:attendance_app/domain/usecases/location/get_locations_usecase.dart';
import 'package:attendance_app/presentation/bloc/attendance/attendance_bloc.dart';
import 'package:attendance_app/presentation/bloc/location/location_bloc.dart';
import 'package:attendance_app/services/gps_service.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // datasource
  sl.registerLazySingleton<LocalDatabase>(() => LocalDatabase());

  // repositories
  sl.registerLazySingleton<LocationRepositoryImpl>(
    () => LocationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<AttendanceRepositoryImpl>(
    () => AttendanceRepositoryImpl(sl()),
  );

  // services
  sl.registerLazySingleton<GpsService>(() => GpsService());

  // usecases
  sl.registerLazySingleton(() => GetLocationsUsecase(sl()));
  sl.registerLazySingleton(() => AddLocationUsecase(sl()));
  sl.registerLazySingleton(() => DeleteLocationUsecase(sl()));
  sl.registerLazySingleton(() => SubmitAttendanceUsecase(sl()));
  sl.registerLazySingleton(() => ValidateRadiusUsecase());
  sl.registerLazySingleton(() => GetAttendanceHistoryUsecase(sl()));

  // blocs
  sl.registerFactory(
    () => LocationBloc(
      getLocationsUsecase: sl(),
      addLocationUsecase: sl(),
      deleteLocationUsecase: sl(),
    ),
  );
  sl.registerFactory(
    () => AttendanceBloc(
      submitAttendanceUsecase: sl(),
      validateRadiusUsecase: sl(),
      getAttendanceHistoryUsecase: sl(),
      attendanceRepository: sl(),
      gpsService: sl(),
    ),
  );
}