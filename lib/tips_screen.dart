import 'dart:ui';
import 'package:flutter/material.dart';
import 'bill_data.dart';
import 'bill_service.dart';
import 'ai_report_service.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "AI Smart Tips",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<List<BillData>>(
        valueListenable: BillService.billsNotifier,
        builder: (context, bills, child) {
          if (bills.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.lightbulb_outline_rounded, size: 64, color: Colors.white24),
                  SizedBox(height: 14),
                  Text("No AI Tips Available", style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text("Scan a bill first to unlock personalized saving tips", style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: bills.length,
            itemBuilder: (context, index) {
              final bill = bills[index];
              final report = AIReportService.generateReport(bill);
              final isExpanded = _expandedIndex == index;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Bar
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _expandedIndex = isExpanded ? null : index;
                              });
                            },
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.amberAccent.withValues(alpha: 0.18),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.lightbulb_rounded, color: Colors.amberAccent, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bill.vendorName,
                                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "₹${bill.amount.toInt()} • ${bill.category}",
                                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Icon(
                                  isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                  color: Colors.white54,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),

                          // Expanded Accordion Details
                          if (isExpanded) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              child: Divider(color: Colors.white12),
                            ),

                            const Text(
                              "Optimized Expense Breakdown",
                              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 14),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _legendItem("Spent", "₹${bill.amount.toInt()}", Colors.redAccent),
                                _legendItem("Save", "₹${report.predictedSavings.toInt()}", Colors.greenAccent),
                                _legendItem("Target", "₹${(bill.amount - report.predictedSavings).clamp(0, bill.amount).toInt()}", const Color(0xFF6366F1)),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Checklist Items
                            ...report.tips.map(
                              (tip) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 18),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        tip,
                                        style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _legendItem(String label, String value, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}