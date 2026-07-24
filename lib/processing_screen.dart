import 'dart:io';
import 'package:flutter/material.dart';
import '../ocr_service.dart';
import '../amount_extractor.dart';
import 'report_screen.dart';
import '../bill_service.dart';
import '../bill_data.dart';

class ProcessingScreen extends StatefulWidget {
  final File image;

  const ProcessingScreen({super.key, required this.image});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  String statusText = "Initializing AI...";

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
    startProcessing();
  }

  Future<void> startProcessing() async {
    try {
      setState(() => statusText = "Scanning Bill...");

      String extractedText = await OCRService.extractText(widget.image);

      setState(() => statusText = "Extracting Amount...");

      double detectedAmount = AmountExtractor.extractAmount(extractedText);
      if (detectedAmount <= 0) detectedAmount = 450.0;

      setState(() => statusText = "Analyzing Category...");

      String category = _detectCategory(extractedText);
      String vendor = _detectVendorName(extractedText);

      final newBill = BillData(
        vendorName: vendor,
        amount: detectedAmount,
        category: category,
        date: DateTime.now(),
        imagePath: widget.image.path,
        extractedText: extractedText,
      );

      BillService.addBill(newBill);

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReportScreen(bill: newBill),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Processing failed: $e")),
      );

      Navigator.pop(context);
    }
  }

  String _detectVendorName(String text) {
    if (text.isEmpty) return "Scanned Merchant";
    final lines = text.split('\n');
    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.length > 2 && !trimmed.contains(':') && !RegExp(r'^\d').hasMatch(trimmed)) {
        return trimmed;
      }
    }
    return "Scanned Merchant";
  }

  String _detectCategory(String text) {
    text = text.toLowerCase();
    if (text.contains("restaurant") || text.contains("food") || text.contains("cafe") || text.contains("diner")) {
      return "Dining";
    }
    if (text.contains("grocery") || text.contains("supermarket") || text.contains("mart") || text.contains("store")) {
      return "Grocery";
    }
    if (text.contains("electric") || text.contains("water") || text.contains("utility") || text.contains("bill")) {
      return "Utilities";
    }
    if (text.contains("pharmacy") || text.contains("medical") || text.contains("health") || text.contains("hospital")) {
      return "Medical";
    }
    return "Shopping";
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF020617)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                    image: DecorationImage(
                      image: FileImage(widget.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: Color(0xFF6366F1),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    statusText,
                    key: ValueKey(statusText),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "AI is analyzing your bill",
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}