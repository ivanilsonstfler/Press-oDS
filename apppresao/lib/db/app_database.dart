import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._privateConstructor();
  static final AppDatabase instance = AppDatabase._privateConstructor();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb('app_pressao.db');
    return _database!;
  }

  Future<Database> _initDb(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Tabela User (equivalente ao seu modelo User)
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            full_name TEXT,
            date_of_birth TEXT,
            weight REAL,
            height REAL,
            blood_type TEXT
          )
        ''');

        // Tabela Medicao (equivalente ao modelo Medicao)
        await db.execute('''
          CREATE TABLE medicoes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sistolica INTEGER NOT NULL,
            diastolica INTEGER NOT NULL,
            data_medicao TEXT NOT NULL,
            notas TEXT,
            remedios_tomados TEXT,
            user_id INTEGER NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }
}
