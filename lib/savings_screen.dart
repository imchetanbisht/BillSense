import 'dart:ui';
import 'package:flutter/material.dart';
import 'bill_data.dart';
import 'bill_service.dart';

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Savings & Budgets",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<List<BillData>>(
        valueListenable: BillService.billsNotifier,
        builder: (context, bills, child) {
          double totalSpent = BillService.totalSpending;
          double totalSavings = BillService.totalEstimatedSavings;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Savings Hero Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF065F46), Color(0xFF047857)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.eco_rounded, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Estimated 2-Month Savings", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text("₹${totalSavings.toInt()}", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Multi-Bar Prediction Chart Frame
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Future Saving Prediction", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          const Text("Projected expense reduction by adopting AI tips", style: TextStyle(color: Colors.white54, fontSize: 12)),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 180,
                            width: double.infinity,
                            child: CustomPaint(
                              painter: MultiBarPredictionPainter(totalSpent: totalSpent, savings: totalSavings),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: const [
                              Text("Now", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                              Text("1 Month", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                              Text("2 Months", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Monthly Category Budgets
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Monthly Category Budgets", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 16),
                          _budgetProgressItem("Grocery", BillService.categoryTotal("Grocery"), 4000, const Color(0xFF6366F1)),
                          const SizedBox(height: 14),
                          _budgetProgressItem("Utilities", BillService.categoryTotal("Utilities"), 5000, Colors.purpleAccent),
                          const SizedBox(height: 14),
                          _budgetProgressItem("Dining", BillService.categoryTotal("Dining"), 3000, Colors.orangeAccent),
                          const SizedBox(height: 14),
                          _budgetProgressItem("Medical", BillService.categoryTotal("Medical"), 2500, Colors.greenAccent),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _budgetProgressItem(String category, double spent, double budget, Color color) {
    double progress = (spent / budget).clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            Text("₹${spent.toInt()} / ₹${budget.toInt()}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            color: color,
            backgroundColor: Colors.white10,
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class MultiBarPredictionPainter extends CustomPainter {
  final double totalSpent;
  final double savings;

  MultiBarPredictionPainter({required this.totalSpent, required this.savings});

  @override
  void paint(Canvas canvas, Size size) {
    double nowVal = totalSpent <= 0 ? 5000 : totalSpent;
    double month1Val = (nowVal - (savings * 0.5)).clamp(0, nowVal);
    double month2Val = (nowVal - savings).clamp(0, nowVal);

    double maxVal = nowVal;

    final bars = [
      {"val": nowVal, "color": Colors.redAccent},
      {"val": month1Val, "color": Colors.orangeAccent},
      {"val": month2Val, "color": Colors.greenAccent},
    ];

    double barWidth = 36;
    double gap = (size.width - (barWidth * 3)) / 4;

    for (int i = 0; i < bars.length; i++) {
      double x = gap + i * (barWidth + gap);
      double val = bars[i]["val"] as double;
      double barHeight = (val / maxVal) * (size.height * 0.8);
      double y = size.height - barHeight;

      final paint = Paint()..color = bars[i]["color"] as Color;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(8),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}