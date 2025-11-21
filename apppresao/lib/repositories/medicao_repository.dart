import 'package:hive_flutter/hive_flutter.dart';

import '../models/medicao.dart';

class MedicaoRepository {
  Box<Map> get _box => Hive.box<Map>('medicoes');

  Future<void> addMedicao(Medicao medicao) async {
    final map = medicao.toMap();
    // salva sem id
    final key = await _box.add(map);
    // atualiza id
    map['id'] = key;
    await _box.put(key, map);
  }

  Future<List<Medicao>> getMedicoesByUser({
    required int userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final result = <Medicao>[];

    for (final raw in _box.values) {
      final map = Map<String, dynamic>.from(raw);

      if (map['user_id'] != userId) continue;

      final med = Medicao.fromMap(map);

      if (startDate != null && med.dataMedicao.isBefore(startDate)) {
        continue;
      }
      if (endDate != null && med.dataMedicao.isAfter(endDate)) {
        continue;
      }

      result.add(med);
    }

    // Ordena do mais recente para o mais antigo (igual ao ORDER BY DESC)
    result.sort((a, b) => b.dataMedicao.compareTo(a.dataMedicao));

    return result;
  }
}
