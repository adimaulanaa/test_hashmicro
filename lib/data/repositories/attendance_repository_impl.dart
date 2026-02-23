import 'package:attendance_app/data/datasources/local_database.dart';
import 'package:attendance_app/data/models/attendance_history_model.dart';
import 'package:attendance_app/data/models/attendance_model.dart';
import 'package:attendance_app/domain/entities/attendance_entity.dart';
import 'package:attendance_app/domain/entities/attendance_history_entity.dart';
import 'package:attendance_app/domain/repositories/attendance_repository.dart';
import 'package:sqflite/sqflite.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final LocalDatabase _localDatabase;

  AttendanceRepositoryImpl(this._localDatabase);

  Future<Database> get _db async => await _localDatabase.database;

  @override
  Future<List<AttendanceEntity>> getAttendances() async {
    final db = await _db;
    final result = await db.query('attendances', orderBy: 'created_at DESC');
    return result.map((map) => AttendanceModel.fromMap(map)).toList();
  }

  @override
  Future<AttendanceEntity?> getTodayAttendance(String locationId) async {
    final db = await _db;
    final today = DateTime.now();
    final startOfDay = DateTime(
      today.year,
      today.month,
      today.day,
    ).toIso8601String();
    final endOfDay = DateTime(
      today.year,
      today.month,
      today.day,
      23,
      59,
      59,
    ).toIso8601String();

    final result = await db.query(
      'attendances',
      where: 'location_id = ? AND created_at BETWEEN ? AND ?',
      whereArgs: [locationId, startOfDay, endOfDay],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return AttendanceModel.fromMap(result.first);
  }

  @override
  Future<void> checkin(AttendanceEntity attendance) async {
    final db = await _db;
    await db.insert(
      'attendances',
      AttendanceModel(
        id: attendance.id,
        locationId: attendance.locationId,
        checkinLatitude: attendance.checkinLatitude,
        checkinLongitude: attendance.checkinLongitude,
        checkinTime: attendance.checkinTime,
        checkinStatus: attendance.checkinStatus,
        createdAt: attendance.createdAt,
      ).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await _insertHistory(
      attendanceId: attendance.id,
      locationId: attendance.locationId,
      latitude: attendance.checkinLatitude!,
      longitude: attendance.checkinLongitude!,
      type: 'checkin',
      status: attendance.checkinStatus!,
      createdAt: attendance.checkinTime!,
    );
  }

  @override
  Future<void> checkout(
    String attendanceId,
    double latitude,
    double longitude,
    DateTime checkoutTime,
    String status,
  ) async {
    final db = await _db;

    await db.update(
      'attendances',
      {
        'checkout_latitude': latitude,
        'checkout_longitude': longitude,
        'checkout_time': checkoutTime.toIso8601String(),
        'checkout_status': status,
      },
      where: 'id = ?',
      whereArgs: [attendanceId],
    );

    final result = await db.query(
      'attendances',
      where: 'id = ?',
      whereArgs: [attendanceId],
      limit: 1,
    );

    if (result.isNotEmpty) {
      final attendance = AttendanceModel.fromMap(result.first);
      await _insertHistory(
        attendanceId: attendanceId,
        locationId: attendance.locationId,
        latitude: latitude,
        longitude: longitude,
        type: 'checkout',
        status: status,
        createdAt: checkoutTime,
      );
    }
  }

  @override
  Future<List<AttendanceHistoryEntity>> getAttendanceHistories() async {
    final db = await _db;
    final result = await db.query(
      'attendance_histories',
      orderBy: 'created_at DESC',
    );
    return result.map((map) => AttendanceHistoryModel.fromMap(map)).toList();
  }

  Future<void> _insertHistory({
    required String attendanceId,
    required String locationId,
    required double latitude,
    required double longitude,
    required String type,
    required String status,
    required DateTime createdAt,
  }) async {
    final db = await _db;
    await db.insert(
      'attendance_histories',
      AttendanceHistoryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        attendanceId: attendanceId,
        locationId: locationId,
        latitude: latitude,
        longitude: longitude,
        type: type,
        status: status,
        createdAt: createdAt,
      ).toMap(),
    );
  }

  @override
  Future<void> insertRejectedHistory({
    required String locationId,
    required double latitude,
    required double longitude,
    required String type,
  }) async {
    await _insertHistory(
      attendanceId: '-', // tidak ada attendance id karena rejected
      locationId: locationId,
      latitude: latitude,
      longitude: longitude,
      type: type,
      status: 'rejected',
      createdAt: DateTime.now(),
    );
  }
}
