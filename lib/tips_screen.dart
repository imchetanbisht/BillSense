import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../bill_service.dart';
import '../ai_savings_service.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {

  Map<int, List<String>> tipsMap = {};
  Map<int, double> savingMap = {};
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
            "No AI tips yet.\nScan a bill first.",
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
        title: const Text("AI Smart Tips"),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: grouped.entries.map((entry) {

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

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

                double optimized =
                    bill.amount - saving;

                return GestureDetector(

                  onTap: () async {

                    /// LOAD AI ONLY FIRST TIME
                    if (tipsMap[index] == null) {

                      loadingMap[index] = true;
                      setState(() {});

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
                          "Unable to generate AI tips right now.",
                          "Try scanning again later."
                        ];

                        savingMap[index] =
                            bill.amount * 0.2;
                      }

                      loadingMap[index] = false;
                    }

                    setState(() {
                      expandedMap[index] =
                      !(expandedMap[index] ?? false);
                    });
                  },

                  child: AnimatedContainer(
                    duration:
                    const Duration(milliseconds: 300),
                    margin:
                    const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1E293B),
                          Color(0xFF020617),
                        ],
                      ),
                      borderRadius:
                      BorderRadius.circular(18),
                      border: Border.all(
                          color: Colors.white12),
                    ),

                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                        /// HEADER
                        Row(
                          children: [

                            const Icon(
                              Icons.lightbulb,
                              color: Colors.orangeAccent,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                "₹${bill.amount.toStringAsFixed(0)} • ${bill.category}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight:
                                  FontWeight.bold,
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

                          const SizedBox(height: 16),

                          if (loading)
                            const Center(
                              child:
                              CircularProgressIndicator(),
                            ),

                          if (!loading) ...[

                            /// PIE CHART
                            SizedBox(
                              height: 180,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 40,
                                  sections: [

                                    PieChartSectionData(
                                      value: bill.amount,
                                      color: Colors.redAccent,
                                      title:
                                      "₹${bill.amount.toInt()}",
                                      radius: 45,
                                      titleStyle:
                                      const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                      ),
                                    ),

                                    PieChartSectionData(
                                      value: saving,
                                      color:
                                      Colors.greenAccent,
                                      title:
                                      "Save\n₹${saving.toInt()}",
                                      radius: 45,
                                      titleStyle:
                                      const TextStyle(
                                        color: Colors.black,
                                        fontSize: 11,
                                      ),
                                    ),

                                    PieChartSectionData(
                                      value: optimized,
                                      color:
                                      Colors.blueAccent,
                                      title:
                                      "After\n₹${optimized.toInt()}",
                                      radius: 45,
                                      titleStyle:
                                      const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            /// TIPS LIST
                            ...tipsMap[index]!.map(
                                  (tip) => Padding(
                                padding:
                                const EdgeInsets.only(
                                    bottom: 8),
                                child: Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
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
                          ]
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
}