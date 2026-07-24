import 'dart:ui';
import 'package:flutter/material.dart';
import 'bill_data.dart';
import 'bill_service.dart';

class InsightScreen extends StatelessWidget {
  const InsightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Spending Insights",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<List<BillData>>(
        valueListenable: BillService.billsNotifier,
        builder: (context, bills, child) {
          double totalSpent = BillService.totalSpending;
          double avgSpent = BillService.averageSpending;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Metric Cards Grid
                Row(
                  children: [
                    Expanded(child: _statCard("Total Spent", "₹${totalSpent.toInt()}", Icons.wallet, const Color(0xFF6366F1))),
                    const SizedBox(width: 12),
                    Expanded(child: _statCard("Total Bills", "${bills.length}", Icons.receipt_long_rounded, Colors.purpleAccent)),
                    const SizedBox(width: 12),
                    Expanded(child: _statCard("Average Bill", "₹${avgSpent.toInt()}", Icons.show_chart_rounded, Colors.cyanAccent)),
                  ],
                ),

                const SizedBox(height: 24),

                // Historical Spending Line & Area Graph Frame
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
                          const Text(
                            "Spending Trajectory",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Historical bill scan trend analysis",
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 180,
                            width: double.infinity,
                            child: CustomPaint(
                              painter: SpendingTrendPainter(bills: bills),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Category Donut Distribution Frame
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
                          const Text(
                            "Category Breakdown",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              SizedBox(
                                height: 130,
                                width: 130,
                                child: CustomPaint(
                                  painter: CategoryDonutPainter(bills: bills),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _categoryLegend("Grocery", BillService.categoryTotal("Grocery"), const Color(0xFF6366F1)),
                                    const SizedBox(height: 8),
                                    _categoryLegend("Utilities", BillService.categoryTotal("Utilities"), Colors.purpleAccent),
                                    const SizedBox(height: 8),
                                    _categoryLegend("Dining", BillService.categoryTotal("Dining"), Colors.orangeAccent),
                                    const SizedBox(height: 8),
                                    _categoryLegend("Medical", BillService.categoryTotal("Medical"), Colors.greenAccent),
                                  ],
                                ),
                              ),
                            ],
                          ),
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

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _categoryLegend(String category, double amount, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(category, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const Spacer(),
        Text("₹${amount.toInt()}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}

class SpendingTrendPainter extends CustomPainter {
  final List<BillData> bills;

  SpendingTrendPainter({required this.bills});

  @override
  void paint(Canvas canvas, Size size) {
    if (bills.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFF6366F1)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF6366F1).withValues(alpha: 0.35), Colors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    double stepX = size.width / (bills.length > 1 ? (bills.length - 1) : 1);
    double maxAmt = bills.map((b) => b.amount).reduce((a, b) => a > b ? a : b);
    if (maxAmt <= 0) maxAmt = 1.0;

    for (int i = 0; i < bills.length; i++) {
      double x = i * stepX;
      double y = size.height - (bills[i].amount / maxAmt * (size.height * 0.7) + size.height * 0.15);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 4.5, Paint()..color = const Color(0xFF6366F1));
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CategoryDonutPainter extends CustomPainter {
  final List<BillData> bills;

  CategoryDonutPainter({required this.bills});

  @override
  void paint(Canvas canvas, Size size) {
    double total = bills.fold(0.0, (sum, b) => sum + b.amount);
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    double startAngle = -1.57;

    final categories = [
      {"cat": "Grocery", "color": const Color(0xFF6366F1)},
      {"cat": "Utilities", "color": Colors.purpleAccent},
      {"cat": "Dining", "color": Colors.orangeAccent},
      {"cat": "Medical", "color": Colors.greenAccent},
    ];

    for (var c in categories) {
      double sum = bills
          .where((b) => b.category.toLowerCase() == (c["cat"] as String).toLowerCase())
          .fold(0.0, (s, b) => s + b.amount);
      if (sum <= 0) continue;

      double sweepAngle = (sum / total) * 6.28;

      final paint = Paint()
        ..color = c["color"] as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 10),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
