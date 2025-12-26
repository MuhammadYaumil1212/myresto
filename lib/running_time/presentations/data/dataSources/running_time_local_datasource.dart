import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/search_log.dart';

class RunningTimeLocalDatasource {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('search_logs.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            method TEXT,
            price INTEGER,
            execution_time_us INTEGER,
            steps INTEGER,
            timestamp TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertLog(SearchLog log) async {
    final db = await database;
    return await db.insert('logs', log.toMap());
  }

  Future<List<SearchLog>> getAllLogs() async {
    final db = await database;
    final result = await db.query('logs', orderBy: 'id DESC');
    return result.map((json) => SearchLog.fromMap(json)).toList();
  }

  Future<void> clearLogs() async {
    final db = await database;
    await db.delete('logs');
  }
}
