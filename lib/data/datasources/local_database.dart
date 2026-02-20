import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  static Database? _database;

  factory LocalDatabase() => _instance;

  LocalDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'attendance.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE locations (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE attendances (
        id TEXT PRIMARY KEY,
        location_id TEXT NOT NULL,
        checkin_latitude REAL,
        checkin_longitude REAL,
        checkin_time TEXT,
        checkin_status TEXT,
        checkout_latitude REAL,
        checkout_longitude REAL,
        checkout_time TEXT,
        checkout_status TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (location_id) REFERENCES locations (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance_histories (
        id TEXT PRIMARY KEY,
        attendance_id TEXT NOT NULL,
        location_id TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (attendance_id) REFERENCES attendances (id),
        FOREIGN KEY (location_id) REFERENCES locations (id)
      )
    ''');
  }
}