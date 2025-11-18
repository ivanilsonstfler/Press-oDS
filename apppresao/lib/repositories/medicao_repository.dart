import 'package:sqflite/sqflite.dart';
import '../db/app_database.dart';
import '../models/medicao.dart';

class MedicaoRepository {
  Future<Database> get _db async => await AppDatabase.instance.database;

  Future<void> addMedicao(Medicao medicao) async {
    final db = await _db;
    await db.insert('medicoes', medicao.toMap());
  }

  Future<List<Medicao>> getMedicoesByUser({
    required int userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _db;
    final where = <String>['user_id = ?'];
    final args = <dynamic>[userId];

    if (startDate != null) {
      where.add('data_medicao >= ?');
      args.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      where.add('data_medicao <= ?');
      args.add(endDate.toIso8601String());
    }

    final res = await db.query(
      'medicoes',
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'data_medicao DESC',
    );

    return res.map((m) => Medicao.fromMap(m)).toList();
  }
}
