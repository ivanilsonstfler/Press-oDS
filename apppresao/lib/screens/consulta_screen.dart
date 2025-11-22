// Importa os pacotes necessários
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/medicao.dart';

// Tela de consulta das medições
class ConsultaScreen extends StatelessWidget {
  // Lista de medições recebida como parâmetro
  final List<Medicao> medicoes;

  const ConsultaScreen({
    super.key,
    required this.medicoes,
  });

  @override
  Widget build(BuildContext context) {
    // Formato de data e hora para exibir as medições
    final fmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        // Título da barra superior
        title: const Text('Modo consulta'),
      ),
      // Corpo da tela
      body: medicoes.isEmpty
          // Caso não haja medições, mostra mensagem centralizada
          ? const Center(
              child: Text(
                'Sem medições para mostrar.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          // Caso haja medições, exibe lista dinâmica
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: medicoes.length,
              itemBuilder: (context, index) {
                // Pega a medição atual
                final m = medicoes[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      // Cor de fundo do card
                      color: const Color(0xFF0F172A),
                      // Bordas arredondadas
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Exibe pressão arterial sistólica/diastólica
                        Text(
                          '${m.sistolica}/${m.diastolica} mmHg',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Exibe status da medição (ex.: "Normal", "Alta")
                        Text(
                          m.status,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Exibe data/hora da medição formatada
                        Text(
                          fmt.format(m.dataMedicao),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                        // Exibe humor, se informado
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
                        // Exibe notas, se houver
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
                        // Exibe remédios tomados, se houver
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