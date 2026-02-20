import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../bill_service.dart';
import 'package:intl/intl.dart';

class InsightScreen extends StatelessWidget {
  const InsightScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final bills = BillService.bills;

    if (bills.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: Text(
            "No Insights Yet\nScan a bill first",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    double total = bills.fold(0, (sum, b) => sum + b.amount);
    double avg = total / bills.length;

    double maxY = bills
        .map((e) => e.amount)
        .reduce((a, b) => a > b ? a : b);

    /// padding for better view
    maxY = maxY + (maxY * 0.3);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      appBar: AppBar(
        title: const Text("Insights"),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// ===== SUMMARY =====
            Container(
              padding: const EdgeInsets.all(20),
              decoration: _card(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat("Total", "₹${total.toStringAsFixed(0)}"),
                  _stat("Bills", bills.length.toString()),
                  _stat("Average", "₹${avg.toStringAsFixed(0)}"),
                ],
              ),
            ),

            const SizedBox(height: 25),

            /// ===== GRAPH =====
            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              decoration: _card(),
              child: LineChart(
                LineChartData(

                  minX: 0,
                  maxX: (bills.length - 1).toDouble() == 0
                      ? 1
                      : (bills.length - 1).toDouble(),

                  minY: 0,
                  maxY: maxY,

                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.white12,
                        strokeWidth: 1,
                      );
                    },
                  ),

                  titlesData: FlTitlesData(

                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            "₹${value.toInt()}",
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),

                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {

                          int index = value.toInt();

                          if (index >= bills.length) {
                            return const SizedBox();
                          }

                          String date =
                          DateFormat('dd/MM')
                              .format(bills[index].date);

                          return Text(
                            date,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),

                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),

                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),

                  borderData: FlBorderData(show: false),

                  lineBarsData: [

                    LineChartBarData(
                      spots: _buildSpots(bills),

                      isCurved: true,
                      barWidth: 4,
                      color: const Color(0xFF6366F1),

                      dotData: FlDotData(
                        show: true,
                        getDotPainter:
                            (spot, percent, barData, index) {

                          return FlDotCirclePainter(
                            radius: 5,
                            color: Colors.white,
                            strokeWidth: 3,
                            strokeColor:
                            const Color(0xFF6366F1),
                          );
                        },
                      ),

                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6366F1)
                                .withOpacity(0.4),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    )
                  ],

                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (spots) {

                        return spots.map((spot) {

                          final bill =
                          bills[spot.x.toInt()];

                          return LineTooltipItem(
                            "₹${bill.amount}\n${DateFormat('dd MMM').format(bill.date)}",
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// ===== LIST =====
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bills.length,
              itemBuilder: (context, index) {

                final bill = bills[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: _card(),
                  child: Row(
                    children: [

                      const Icon(Icons.receipt,
                          color: Colors.white),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [

                            Text(
                              bill.category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(
                              DateFormat('dd MMM yyyy')
                                  .format(bill.date),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Text(
                        "₹${bill.amount}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  /// CARD STYLE
  BoxDecoration _card() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.08),
          Colors.white.withOpacity(0.02),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white12),
    );
  }

  /// SUMMARY STAT
  Widget _stat(String title, String value) {
    return Column(
      children: [

        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          title,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// GRAPH DATA
  List<FlSpot> _buildSpots(List bills) {

    if (bills.length == 1) {
      /// center single point
      return [
        FlSpot(0, bills[0].amount),
        FlSpot(1, bills[0].amount),
      ];
    }

    List<FlSpot> spots = [];

    for (int i = 0; i < bills.length; i++) {
      spots.add(
        FlSpot(
          i.toDouble(),
          bills[i].amount.toDouble(),
        ),
      );
    }

    return spots;
  }
}
