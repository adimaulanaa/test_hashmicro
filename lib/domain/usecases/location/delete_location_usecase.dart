import 'package:attendance_app/domain/repositories/location_repository.dart';

class DeleteLocationUsecase {
  final LocationRepository _repository;

  DeleteLocationUsecase(this._repository);

  Future<void> call(String id) async {
    await _repository.deleteLocation(id);
  }
}