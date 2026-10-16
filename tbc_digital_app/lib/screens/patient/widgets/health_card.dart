import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'chart_card.dart';
import 'legend_item.dart';

class HealthChart extends StatelessWidget {
  final List<double> bmi;
  final List<double> bb;
  final List<double> tb;

  const HealthChart({
    super.key,
    required this.bmi,
    required this.bb,
    required this.tb,
  });

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      title: "Grafik Kesehatan",
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  _line(bmi, Colors.green),
                  _line(bb, Colors.blue),
                  _line(tb, Colors.purple),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              LegendItem(color: Colors.green, text: "GIZI"),
              LegendItem(color: Colors.blue, text: "BB"),
              LegendItem(color: Colors.purple, text: "TB"),
            ],
          )
        ],
      ),
    );
  }

  LineChartBarData _line(List<double> data, Color color) {
    return LineChartBarData(
      isCurved: true,
      color: color,
      barWidth: 3,
      spots: List.generate(
        data.length,
        (i) => FlSpot(i.toDouble(), data[i]),
      ),
    );
  }
}