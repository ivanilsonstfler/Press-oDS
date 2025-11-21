import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/medicao.dart';

class PressureChartTab extends StatelessWidget {
  final List<Medicao> medicoes;

  const PressureChartTab({
    super.key,
    required this.medicoes,
  });

  @override
  Widget build(BuildContext context) {
    if (medicoes.isEmpty) {
      return const Center(
        child: Text(
          'Cadastre medições para ver o gráfico.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    // Pega no máximo as últimas 20 medições
    final data = medicoes.take(20).toList().reversed.toList();
    final minX = 0.0;
    final maxX = (data.length - 1).toDouble();

    int maxSistolica = data.map((m) => m.sistolica).reduce((a, b) => a > b ? a : b);
    int maxDiastolica = data.map((m) => m.diastolica).reduce((a, b) => a > b ? a : b);
    final maxY = ([
      maxSistolica,
      maxDiastolica,
      180,
    ]..sort())
        .last
        .toDouble();

    final dateFmt = DateFormat('dd/MM');

    List<FlSpot> sistolicaSpots = [];
    List<FlSpot> diastolicaSpots = [];

    for (int i = 0; i < data.length; i++) {
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
              const Text(
                'Evolução da pressão',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: LineChart(
                  LineChartData(
                    minX: minX,
                    maxX: maxX,
                    minY: 40,
                    maxY: maxY,
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: 20,
                          getTitlesWidget: (value, meta) => Text(
                            '${value.toInt()}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= data.length) {
                              return const SizedBox.shrink();
                            }
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
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (value) => FlLine(
                        strokeWidth: 0.5,
                        color: Colors.white24,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: sistolicaSpots,
                        isCurved: true,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                      ),
                      LineChartBarData(
                        spots: diastolicaSpots,
                        isCurved: true,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final med = data[spot.x.toInt()];
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

class _LegendDot extends StatelessWidget {
  final String label;

  const _LegendDot({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(radius: 4),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
