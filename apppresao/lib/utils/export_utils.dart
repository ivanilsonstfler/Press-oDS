import 'package:intl/intl.dart';
import '../models/medicao.dart';

class ExportUtils {
  static String medicoesToCsv(List<Medicao> medicoes) {
    final fmt = DateFormat('yyyy-MM-dd HH:mm');
    final buffer = StringBuffer();

    buffer.writeln(
        'data_hora,sistolica,diastolica,status,humor,notas,remedios');

    for (final m in medicoes) {
      final data = fmt.format(m.dataMedicao);
      final notas = (m.notas ?? '').replaceAll(',', ';');
      final remedios = (m.remediosTomados ?? '').replaceAll(',', ';');
      final humor = (m.humor ?? '').replaceAll(',', ';');

      buffer.writeln(
        '$data,${m.sistolica},${m.diastolica},${m.status},$humor,$notas,$remedios',
      );
    }

    return buffer.toString();
  }
}
