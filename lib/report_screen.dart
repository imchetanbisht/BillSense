import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../ai_report_service.dart';

class ReportScreen extends StatefulWidget {
  final File image;
  final double amount;
  final String category;
  final String extractedText;

  const ReportScreen({
    super.key,
    required this.image,
    required this.amount,
    required this.category,
    required this.extractedText,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {

  String insight = "";
  String suggestion = "";
  double predictedSaving = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAI();
  }

  Future<void> loadAI() async {

    try {

      final result = await AIReportService.generateReport(
        amount: widget.amount,
        category: widget.category,
        extractedText: widget.extractedText,
      );

      insight = result["insight"] ?? "";
      suggestion = result["suggestion"] ?? "";

      predictedSaving = (result["saving"] is num)
          ? (result["saving"] as num).toDouble()
          : widget.amount * 0.25;

    } catch (e) {

      insight =
      "Your spending pattern shows moderate behaviour in ${widget.category}.";
      suggestion =
      "Reducing unnecessary purchases by 10-15% may improve savings.";
      predictedSaving = widget.amount * 0.25;
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("AI Expense Report"),
        centerTitle: true,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.file(
                widget.image,
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            _summaryCard(),
            const SizedBox(height: 16),
            _aiInsightCard(),
            const SizedBox(height: 16),
            _savingCard(),
            const SizedBox(height: 20),

            _premiumChartCard(),
          ],
        ),
      ),
    );
  }

  /// ================= PREMIUM CHART =================
  Widget _premiumChartCard() {

    double maxY = _calculateMaxY();

    return Container(
      height: 260,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 2,
          minY: 0,
          maxY: maxY,

          gridData: FlGridData(
            show: true,
            horizontalInterval: maxY / 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.white10,
                strokeWidth: 1,
              );
            },
          ),

          borderData: FlBorderData(show: false),

          titlesData: FlTitlesData(

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 34,
                getTitlesWidget: (value, meta) {

                  if (value % 1 != 0) {
                    return const SizedBox();
                  }

                  switch (value.toInt()) {
                    case 0:
                      return _bottomLabel("Now", Alignment.centerLeft);
                    case 1:
                      return _bottomLabel("1 Month", Alignment.center);
                    case 2:
                      return _bottomLabel("2 Months", Alignment.centerLeft); // 👈 shifted left
                  }

                  return const SizedBox();
                },
              ),
            ),

            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: maxY / 5,
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

            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),

          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.black87,
              getTooltipItems: (spots) {
                return spots.map((spot) {
                  return LineTooltipItem(
                    "₹${spot.y.toStringAsFixed(0)}",
                    const TextStyle(color: Colors.white),
                  );
                }).toList();
              },
            ),
          ),

          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, widget.amount),
                FlSpot(1, predictedSaving),
                FlSpot(2, predictedSaving * 1.2),
              ],
              isCurved: true,
              barWidth: 4,
              color: Colors.greenAccent,

              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 5,
                    color: Colors.greenAccent,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),

              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.greenAccent.withOpacity(0.3),
                    Colors.greenAccent.withOpacity(0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateMaxY() {

    double maxValue = [
      widget.amount,
      predictedSaving,
      predictedSaving * 1.2
    ].reduce((a, b) => a > b ? a : b);

    return (maxValue * 1.4).ceilToDouble();
  }

  Widget _bottomLabel(String text, Alignment alignment) {
    return SizedBox(
      width: 80,
      child: Align(
        alignment: alignment,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// ================= SUMMARY =================
  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Row(
        children: [

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.wallet,
                color: Colors.indigoAccent),
          ),

          const SizedBox(width: 14),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                widget.category,
                style: const TextStyle(
                    color: Colors.white54),
              ),

              Text(
                "₹${widget.amount.toStringAsFixed(0)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _aiInsightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "AI Insight",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            insight,
            style: const TextStyle(
                color: Colors.white70,
                height: 1.4),
          ),

          const SizedBox(height: 14),

          const Text(
            "Suggestion",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Text(
            suggestion,
            style: const TextStyle(
                color: Colors.white70,
                height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _savingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Text(
        "Estimated Saving in next 2 months: ₹${predictedSaving.toStringAsFixed(0)}",
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.08),
          Colors.white.withOpacity(0.02),
        ],
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white12),
    );
  }
}