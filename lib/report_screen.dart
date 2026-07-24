import 'dart:ui';
import 'package:flutter/material.dart';
import 'bill_data.dart';
import 'bill_service.dart';
import 'ai_report_service.dart';

class ReportScreen extends StatelessWidget {
  final BillData bill;

  const ReportScreen({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    final report = AIReportService.generateReport(bill);

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "AI Expense Report",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Receipt Header Image Frame
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF312E81), Color(0xFF4C1D95)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.description_rounded, size: 48, color: Colors.white70),
                  SizedBox(height: 8),
                  Text(
                    "Scanned Receipt Processed",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Vendor & Extracted Final Total Header Card
            ClipRRect(
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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.store_rounded, color: Color(0xFF6366F1), size: 28),
                      ),

                      const SizedBox(width: 14),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bill.vendorName,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            bill.category,
                            style: const TextStyle(color: Color(0xFF6366F1), fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),

                      const Spacer(),

                      Text(
                        "₹${bill.amount.toInt()}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // AI Insight & Smart Suggestion Box
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
                      Row(
                        children: const [
                          Icon(Icons.auto_awesome, color: Color(0xFF6366F1), size: 20),
                          SizedBox(width: 8),
                          Text("AI Expense Insight", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        report.insightText,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(color: Colors.white12),
                      ),

                      Row(
                        children: const [
                          Icon(Icons.lightbulb_rounded, color: Colors.amberAccent, size: 20),
                          SizedBox(width: 8),
                          Text("Smart Suggestion", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        report.suggestionText,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Estimated Savings Callout Box
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.eco_rounded, color: Colors.greenAccent, size: 30),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Estimated 2-Month Savings", style: TextStyle(color: Colors.white54, fontSize: 12)),
                      Text(
                        "₹${report.predictedSavings.toInt()}",
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Savings Curve Chart Frame
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
                      const Text("Predicted Savings Curve", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 160,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: SavingsLineChartPainter(amount: bill.amount, savings: report.predictedSavings),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("Now", style: TextStyle(color: Colors.white54, fontSize: 12)),
                          Text("1 Month", style: TextStyle(color: Colors.white54, fontSize: 12)),
                          Text("2 Months", style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Save & Finish Button
            ElevatedButton(
              onPressed: () {
                BillService.addBill(bill);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                minimumSize: const Size(double.infinity, 54),
                elevation: 8,
                shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                "Save Bill & Finish",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class SavingsLineChartPainter extends CustomPainter {
  final double amount;
  final double savings;

  SavingsLineChartPainter({required this.amount, required this.savings});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.greenAccent.withValues(alpha: 0.3), Colors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    double p1Y = size.height * 0.2;
    double p2Y = size.height * 0.5;
    double p3Y = size.height * 0.8;

    path.moveTo(0, p1Y);
    path.quadraticBezierTo(size.width * 0.5, p2Y, size.width, p3Y);

    fillPath.moveTo(0, p1Y);
    fillPath.quadraticBezierTo(size.width * 0.5, p2Y, size.width, p3Y);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    final dotPaint = Paint()..color = Colors.greenAccent;
    canvas.drawCircle(Offset(0, p1Y), 5, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.5, p2Y), 5, dotPaint);
    canvas.drawCircle(Offset(size.width, p3Y), 5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}