import 'package:attendance_app/domain/entities/location_entity.dart';
import 'package:attendance_app/domain/repositories/location_repository.dart';

class AddLocationUsecase {
  final LocationRepository _repository;

  AddLocationUsecase(this._repository);

  Future<void> call(LocationEntity location) async {
    await _repository.addLocation(location);
  }
}