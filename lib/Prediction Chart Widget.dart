import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SavingChart extends StatelessWidget {
  const SavingChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 12000),
                FlSpot(1, 12500),
              ],
              isCurved: true,
              color: Colors.red,
              barWidth: 3,
            ),
            LineChartBarData(
              spots: const [
                FlSpot(0, 10200),
                FlSpot(1, 9800),
              ],
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
