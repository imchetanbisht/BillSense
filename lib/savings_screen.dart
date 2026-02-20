import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../bill_service.dart';
import '../ai_savings_service.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({super.key});

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {

  Map<int, List<String>> tipsMap = {};
  Map<int, double> savingMap = {};   // ✅ FIX ADDED
  Map<int, bool> expandedMap = {};
  Map<int, bool> loadingMap = {};

  @override
  Widget build(BuildContext context) {

    final bills = BillService.bills;

    if (bills.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: Text(
            "No savings data yet.\nScan a bill first.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    /// GROUP BY DATE
    Map<String, List<int>> grouped = {};

    for (int i = 0; i < bills.length; i++) {

      final bill = bills[i];

      String key =
          "${bill.date.day}/${bill.date.month}/${bill.date.year}";

      grouped.putIfAbsent(key, () => []).add(i);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("AI Savings"),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: grouped.entries.map((entry) {

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// DATE HEADER
              Text(
                entry.key,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              ...entry.value.map((index) {

                final bill = bills[index];

                bool expanded = expandedMap[index] ?? false;
                bool loading = loadingMap[index] ?? false;

                double saving =
                    savingMap[index] ?? bill.amount * 0.2;

                return GestureDetector(

                  onTap: () async {

                    /// LOAD AI ONLY FIRST TIME
                    if (tipsMap[index] == null) {

                      setState(() {
                        loadingMap[index] = true;
                      });

                      try {

                        final result =
                        await AISavingsService.generateTips(
                          amount: bill.amount,
                          category: bill.category,
                        );

                        tipsMap[index] =
                        List<String>.from(result["tips"]);

                        savingMap[index] =
                            (result["saving"] as num?)
                                ?.toDouble()
                                ?? bill.amount * 0.2;

                      } catch (e) {

                        tipsMap[index] = [
                          "Unable to generate AI tips.",
                          "Please try again later."
                        ];

                        savingMap[index] =
                            bill.amount * 0.2;
                      }

                      setState(() {
                        loadingMap[index] = false;
                      });
                    }

                    setState(() {
                      expandedMap[index] =
                      !(expandedMap[index] ?? false);
                    });
                  },

                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1E293B),
                          Color(0xFF020617),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white12),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// HEADER
                        Row(
                          children: [

                            const Icon(
                              Icons.savings,
                              color: Colors.greenAccent,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                "₹${bill.amount.toStringAsFixed(0)} • ${bill.category}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            Icon(
                              expanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.white54,
                            ),
                          ],
                        ),

                        /// EXPANDED CONTENT
                        if (expanded) ...[

                          const SizedBox(height: 14),

                          /// LOADING
                          if (loading)
                            const Center(
                              child:
                              CircularProgressIndicator(),
                            ),

                          /// TIPS
                          if (!loading &&
                              tipsMap[index] != null)
                            ...tipsMap[index]!
                                .map(
                                  (tip) => Padding(
                                padding:
                                const EdgeInsets.only(
                                    bottom: 8),
                                child: Row(
                                  children: [

                                    const Icon(
                                      Icons.check_circle,
                                      size: 18,
                                      color:
                                      Colors.greenAccent,
                                    ),

                                    const SizedBox(width: 8),

                                    Expanded(
                                      child: Text(
                                        tip,
                                        style:
                                        const TextStyle(
                                          color:
                                          Colors.white70,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: 16),

                          /// GRAPH TITLE
                          Text(
                            "Future Saving Prediction",
                            style: TextStyle(
                              color: Colors.white
                                  .withOpacity(0.9),
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          SizedBox(
                            height: 180,
                            child: _buildBarChart(
                                bill.amount,
                                saving
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// ================= BAR GRAPH =================

  Widget _buildBarChart(
      double amount,
      double saving,
      ) {

    double month1 = amount - saving * 0.5;
    double month2 = amount - saving;

    return BarChart(
      BarChartData(

        borderData: FlBorderData(show: false),

        gridData: FlGridData(
          show: true,
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
              getTitlesWidget: (value, meta) {

                switch (value.toInt()) {
                  case 0:
                    return const Text("Now",
                        style: TextStyle(
                            color: Colors.white54));
                  case 1:
                    return const Text("1M",
                        style: TextStyle(
                            color: Colors.white54));
                  case 2:
                    return const Text("2M",
                        style: TextStyle(
                            color: Colors.white54));
                }

                return const SizedBox();
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

        barGroups: [

          _bar(0, amount, Colors.redAccent),
          _bar(1, month1, Colors.orangeAccent),
          _bar(2, month2, Colors.greenAccent),
        ],
      ),
    );
  }

  BarChartGroupData _bar(
      int x,
      double value,
      Color color,
      ) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          width: 18,
          borderRadius: BorderRadius.circular(6),
          color: color,
        )
      ],
    );
  }
}