import 'package:attendance_app/presentation/bloc/location/location_event.dart';
import 'package:attendance_app/presentation/bloc/location/location_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/location_entity.dart';
import '../../../domain/usecases/location/add_location_usecase.dart';
import '../../../domain/usecases/location/delete_location_usecase.dart';
import '../../../domain/usecases/location/get_locations_usecase.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final GetLocationsUsecase _getLocationsUsecase;
  final AddLocationUsecase _addLocationUsecase;
  final DeleteLocationUsecase _deleteLocationUsecase;

  LocationBloc({
    required GetLocationsUsecase getLocationsUsecase,
    required AddLocationUsecase addLocationUsecase,
    required DeleteLocationUsecase deleteLocationUsecase,
  })  : _getLocationsUsecase = getLocationsUsecase,
        _addLocationUsecase = addLocationUsecase,
        _deleteLocationUsecase = deleteLocationUsecase,
        super(LocationInitial()) {
    on<GetLocationsEvent>(_onGetLocations);
    on<AddLocationEvent>(_onAddLocation);
    on<DeleteLocationEvent>(_onDeleteLocation);
  }

  Future<void> _onGetLocations(
    GetLocationsEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    try {
      final locations = await _getLocationsUsecase();
      emit(LocationLoaded(locations));
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onAddLocation(
    AddLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    try {
      final location = LocationEntity(
        id: const Uuid().v4(),
        name: event.name,
        latitude: event.latitude,
        longitude: event.longitude,
        address: event.address,
        createdAt: DateTime.now(),
      );
      await _addLocationUsecase(location);
      final locations = await _getLocationsUsecase();
      emit(LocationLoaded(locations));
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onDeleteLocation(
    DeleteLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    try {
      await _deleteLocationUsecase(event.id);
      final locations = await _getLocationsUsecase();
      emit(LocationLoaded(locations));
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }
}