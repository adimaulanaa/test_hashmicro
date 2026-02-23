import 'package:attendance_app/data/datasources/local_database.dart';
import 'package:attendance_app/data/models/location_model.dart';
import 'package:attendance_app/domain/entities/location_entity.dart';
import 'package:attendance_app/domain/repositories/location_repository.dart';
import 'package:sqflite/sqflite.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocalDatabase _localDatabase;

  LocationRepositoryImpl(this._localDatabase);

  Future<Database> get _db async => await _localDatabase.database;

  @override
  Future<List<LocationEntity>> getLocations() async {
    final db = await _db;
    final result = await db.query('locations', orderBy: 'created_at DESC');
    return result.map((map) => LocationModel.fromMap(map)).toList();
  }

  @override
  Future<void> addLocation(LocationEntity location) async {
    final db = await _db;
    await db.insert(
      'locations',
      LocationModel(
        id: location.id,
        name: location.name,
        latitude: location.latitude,
        longitude: location.longitude,
        address: location.address,
        createdAt: location.createdAt,
      ).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteLocation(String id) async {
    final db = await _db;
    await db.delete('locations', where: 'id = ?', whereArgs: [id]);
  }
}