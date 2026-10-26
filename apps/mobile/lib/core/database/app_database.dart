// apps/mobile/lib/core/database/app_database.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('rural_health_offline.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. User Profile Table
    await db.execute('''
      CREATE TABLE profiles (
        id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        date_of_birth TEXT NOT NULL,
        gender TEXT NOT NULL,
        village_name TEXT NOT NULL,
        district_name TEXT NOT NULL,
        preferred_language TEXT NOT NULL DEFAULT 'hi',
        emergency_contact_phone TEXT NOT NULL,
        known_allergies TEXT,
        existing_conditions TEXT,
        is_pregnant INTEGER DEFAULT 0,
        lmp_date TEXT,
        updated_at TEXT NOT NULL
      )
    ''');

    // 2. Medicine Reminders
    await db.execute('''
      CREATE TABLE medicine_reminders (
        id TEXT PRIMARY KEY,
        medicine_name TEXT NOT NULL,
        dosage_instruction TEXT NOT NULL,
        frequency_per_day INTEGER NOT NULL,
        reminder_times TEXT NOT NULL, -- JSON Array string
        start_date TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        updated_at TEXT NOT NULL
      )
    ''');

    // 3. Offline Sync Event Queue
    await db.execute('''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        entity_name TEXT NOT NULL,
        action_type TEXT NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
        payload TEXT NOT NULL,      -- JSON Stringified payload
        created_at TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending' -- 'pending', 'syncing', 'failed'
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
