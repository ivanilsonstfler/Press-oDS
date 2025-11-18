class Medicao {
  final int? id;
  final int sistolica;
  final int diastolica;
  final DateTime dataMedicao;
  final String? notas;
  final String? remediosTomados;
  final int userId;

  Medicao({
    this.id,
    required this.sistolica,
    required this.diastolica,
    required this.dataMedicao,
    this.notas,
    this.remediosTomados,
    required this.userId,
  });

  /// Mesma lógica de status que seu /get_medicoes do Flask
  String get status {
    if (sistolica >= 140 || diastolica >= 90) {
      return 'Hipertensão Estágio 2';
    } else if (sistolica >= 130 || diastolica >= 80) {
      return 'Hipertensão Estágio 1';
    } else if (sistolica >= 120 && diastolica < 80) {
      return 'Elevada';
    }
    return 'Normal';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sistolica': sistolica,
      'diastolica': diastolica,
      'data_medicao': dataMedicao.toIso8601String(),
      'notas': notas,
      'remedios_tomados': remediosTomados,
      'user_id': userId,
    };
  }

  factory Medicao.fromMap(Map<String, dynamic> map) {
    return Medicao(
      id: map['id'] as int?,
      sistolica: map['sistolica'] as int,
      diastolica: map['diastolica'] as int,
      dataMedicao: DateTime.parse(map['data_medicao'] as String),
      notas: map['notas'] as String?,
      remediosTomados: map['remedios_tomados'] as String?,
      userId: map['user_id'] as int,
    );
  }
}
