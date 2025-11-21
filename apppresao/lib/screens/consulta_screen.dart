import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/medicao.dart';

class ConsultaScreen extends StatelessWidget {
  final List<Medicao> medicoes;

  const ConsultaScreen({
    super.key,
    required this.medicoes,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modo consulta'),
      ),
      body: medicoes.isEmpty
          ? const Center(
              child: Text(
                'Sem medições para mostrar.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: medicoes.length,
              itemBuilder: (context, index) {
                final m = medicoes[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${m.sistolica}/${m.diastolica} mmHg',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          m.status,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fmt.format(m.dataMedicao),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                        if (m.humor != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Como estava: ${m.humor}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        if (m.notas != null && m.notas!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Notas: ${m.notas}',
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        if (m.remediosTomados != null &&
                            m.remediosTomados!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Remédios: ${m.remediosTomados}',
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
