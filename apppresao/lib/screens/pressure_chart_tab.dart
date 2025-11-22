```dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/medicao.dart';

// Aba responsável por mostrar o gráfico de evolução da pressão arterial
class PressureChartTab extends StatelessWidget {
  // Lista de medições que será usada para montar o gráfico
  final List<Medicao> medicoes;

  const PressureChartTab({
    super.key,
    required this.medicoes,
  });

  @override
  Widget build(BuildContext context) {
    // Se não houver medições, mostra apenas uma mensagem informativa
    if (medicoes.isEmpty) {
      return const Center(
        child: Text(
          'Cadastre medições para ver o gráfico.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    // Pega no máximo as últimas 20 medições
    // - take(20): pega até 20 do início da lista
    // - toList(): converte para lista
    // - reversed.toList(): inverte para que as mais recentes fiquem no final
    final data = medicoes.take(20).toList().reversed.toList();

    // Eixo X: índice (0, 1, 2, ...). minX = 0, maxX = número de pontos - 1
    final minX = 0.0;
    final maxX = (data.length - 1).toDouble();

    // Descobre a pressão sistólica máxima entre as medições
    int maxSistolica = data.map((m) => m.sistolica).reduce((a, b) => a > b ? a : b);
    // Descobre a pressão diastólica máxima entre as medições
    int maxDiastolica = data.map((m) => m.diastolica).reduce((a, b) => a > b ? a : b);

    // Define o valor máximo do eixo Y com base na maior pressão e um limite mínimo de 180
    // - Coloca maxSistolica, maxDiastolica e 180 em uma lista
    // - Ordena a lista
    // - Pega o último elemento (maior valor)
    final maxY = ([
      maxSistolica,
      maxDiastolica,
      180,
    ]..sort())
        .last
        .toDouble();

    // Formato de data para mostrar no eixo X e nos tooltips (dd/MM)
    final dateFmt = DateFormat('dd/MM');

    // Pontos da curva de sistólica
    List<FlSpot> sistolicaSpots = [];
    // Pontos da curva de diastólica
    List<FlSpot> diastolicaSpots = [];

    // Preenche as listas de pontos (cada medição vira um ponto no gráfico)
    for (int i = 0; i < data.length; i++) {
      // x = índice, y = valor da pressão
      sistolicaSpots.add(FlSpot(i.toDouble(), data[i].sistolica.toDouble()));
      diastolicaSpots.add(FlSpot(i.toDouble(), data[i].diastolica.toDouble()));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Título da seção do gráfico
              const Text(
                'Evolução da pressão',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              // Expanded para o gráfico ocupar o espaço restante dentro do Card
              Expanded(
                child: LineChart(
                  LineChartData(
                    // Limites do eixo X (posição dos pontos)
                    minX: minX,
                    maxX: maxX,
                    // Limites do eixo Y (valores de pressão)
                    minY: 40,
                    maxY: maxY,
                    // Configuração dos títulos dos eixos
                    titlesData: FlTitlesData(
                      // Títulos do eixo Y (esquerda)
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40, // espaço reservado para os textos
                          interval: 20, // intervalo entre marcas (40, 60, 80...)
                          getTitlesWidget: (value, meta) => Text(
                            '${value.toInt()}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                      // Títulos do eixo X (base, datas)
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1, // mostra título para cada ponto (índice inteiro)
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            // Garante que o índice é válido dentro da lista
                            if (index < 0 || index >= data.length) {
                              return const SizedBox.shrink();
                            }
                            // Mostra a data da medição naquele ponto
                            return Text(
                              dateFmt.format(data[index].dataMedicao),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                      // Oculta títulos no topo
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      // Oculta títulos à direita
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    // Configuração da grade (linhas do gráfico)
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false, // não desenha linhas verticais
                      horizontalInterval: 20, // distância entre as linhas horizontais
                      getDrawingHorizontalLine: (value) => FlLine(
                        strokeWidth: 0.5,
                        color: Colors.white24,
                      ),
                    ),
                    // Sem borda ao redor do gráfico
                    borderData: FlBorderData(show: false),
                    // Dados das linhas (sistólica + diastólica)
                    lineBarsData: [
                      // Linha de sistólica
                      LineChartBarData(
                        spots: sistolicaSpots,
                        isCurved: true, // curva suavizada
                        barWidth: 3,
                        dotData: const FlDotData(show: false), // não mostra os pontos
                      ),
                      // Linha de diastólica
                      LineChartBarData(
                        spots: diastolicaSpots,
                        isCurved: true,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                    // Configuração de interação/touch no gráfico
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        // Define o conteúdo do tooltip quando o usuário toca no gráfico
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final med = data[spot.x.toInt()];
                            // Mostra data e valores de sistólica/diastólica
                            return LineTooltipItem(
                              '${dateFmt.format(med.dataMedicao)}\n'
                              'Sist: ${med.sistolica}  Diast: ${med.diastolica}',
                              const TextStyle(color: Colors.white),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Legenda das linhas (Sistólica / Diastólica)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _LegendDot(label: 'Sistólica'),
                  SizedBox(width: 16),
                  _LegendDot(label: 'Diastólica'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget simples para representar um item de legenda com ponto + texto
class _LegendDot extends StatelessWidget {
  // Texto da legenda (ex.: "Sistólica", "Diastólica")
  final String label;

  const _LegendDot({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Pequeno círculo usado como marcador de legenda
        const CircleAvatar(radius: 4),
        const SizedBox(width: 4),
        // Texto da legenda
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
```
