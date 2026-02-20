import 'package:attendance_app/domain/entities/location_entity.dart';
import 'package:attendance_app/domain/repositories/location_repository.dart';

class GetLocationsUsecase {
  final LocationRepository _repository;

  GetLocationsUsecase(this._repository);

  Future<List<LocationEntity>> call() async {
    return await _repository.getLocations();
  }
}