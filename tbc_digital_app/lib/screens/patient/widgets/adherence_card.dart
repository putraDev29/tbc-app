import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'chart_card.dart';

class AdherenceChart extends StatelessWidget {
  final int patuh;
  final int terlambat;
  final int tidak;

  const AdherenceChart({
    super.key,
    required this.patuh,
    required this.terlambat,
    required this.tidak,
  });

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      title: "Grafik Kepatuhan",
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [
              BarChartRodData(toY: patuh.toDouble(), color: Colors.green)
            ]),
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(toY: terlambat.toDouble(), color: Colors.orange)
            ]),
            BarChartGroupData(x: 2, barRods: [
              BarChartRodData(toY: tidak.toDouble(), color: Colors.red)
            ]),
          ],
        ),
      ),
    );
  }
}