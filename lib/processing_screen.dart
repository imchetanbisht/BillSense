import 'dart:io';
import 'package:flutter/material.dart';
import '../ocr_service.dart';
import 'report_screen.dart';
import '../bill_service.dart';

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

      String extractedText =
      await OCRService.extractText(widget.image);

      print("📄 OCR TEXT:\n$extractedText");

      setState(() => statusText = "Extracting Amount...");

      double detectedAmount =
      _detectAmountLensStyle(extractedText);

      print("💰 FINAL AMOUNT: $detectedAmount");

      setState(() => statusText = "Analyzing Category...");

      String category =
      _detectCategory(extractedText);

      BillService.addOrUpdateBill(
        amount: detectedAmount,
        category: category,
        imagePath: widget.image.path,
      );

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReportScreen(
            image: widget.image,
            amount: detectedAmount,
            category: category,
            extractedText: extractedText,
          ),
        ),
      );

    } catch (e) {

      print("❌ ERROR: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Processing failed: $e")),
      );

      Navigator.pop(context);
    }
  }

  /// ============================================================
  /// 🔥 GOOGLE LENS STYLE AMOUNT DETECTION
  /// ============================================================
  double _detectAmountLensStyle(String text) {

    text = text.toLowerCase();

    text = text.replaceAll("₹", "");
    text = text.replaceAll("rs.", "");
    text = text.replaceAll("rs", "");

    List<String> lines = text.split("\n");

    double bestAmount = 0;
    int bestScore = 0;

    for (String line in lines) {

      double? value = _extractLastNumber(line);

      if (value == null) continue;

      if (value < 10 || value > 100000) continue;

      int score = 0;

      /// Keyword scoring
      if (_containsKeyword(line, "grand total")) score += 100;
      if (_containsKeyword(line, "amount payable")) score += 95;
      if (_containsKeyword(line, "net payable")) score += 90;
      if (_containsKeyword(line, "total")) score += 80;
      if (_containsKeyword(line, "subtotal")) score -= 20;
      if (_containsKeyword(line, "tax")) score -= 10;
      if (_containsKeyword(line, "gst")) score -= 10;

      /// Currency pattern bonus
      if (line.contains(".00")) score += 5;

      /// Position bonus (totals usually lower part)
      if (lines.indexOf(line) > lines.length * 0.5) {
        score += 10;
      }

      if (score > bestScore) {
        bestScore = score;
        bestAmount = value;
      }
    }

    if (bestAmount > 0) return bestAmount;

    /// Fallback → largest realistic number
    return _fallbackLargest(text);
  }

  /// Fuzzy keyword match
  bool _containsKeyword(String line, String keyword) {

    line = line.replaceAll("0", "o");
    line = line.replaceAll("1", "l");

    return line.contains(keyword);
  }

  /// Extract last number
  double? _extractLastNumber(String line) {

    RegExp regex = RegExp(r'\d+[.,]?\d*');

    Iterable<Match> matches = regex.allMatches(line);

    if (matches.isEmpty) return null;

    String last = matches.last.group(0)!;

    return double.tryParse(last.replaceAll(",", ""));
  }

  /// Fallback biggest number
  double _fallbackLargest(String text) {

    RegExp regex = RegExp(r'\d+[.,]?\d*');

    Iterable<Match> matches = regex.allMatches(text);

    double max = 0;

    for (var m in matches) {

      String raw = m.group(0)!;

      if (raw.length > 6) continue;

      double? value =
      double.tryParse(raw.replaceAll(",", ""));

      if (value != null &&
          value > max &&
          value < 100000 &&
          value > 20) {

        max = value;
      }
    }

    return max;
  }

  /// CATEGORY DETECTION
  String _detectCategory(String text) {

    text = text.toLowerCase();

    if (text.contains("restaurant") ||
        text.contains("food") ||
        text.contains("cafe") ||
        text.contains("dine")) {
      return "Food";
    }

    if (text.contains("mall") ||
        text.contains("store") ||
        text.contains("mart") ||
        text.contains("shop")) {
      return "Shopping";
    }

    if (text.contains("uber") ||
        text.contains("taxi") ||
        text.contains("travel") ||
        text.contains("bus")) {
      return "Travel";
    }

    if (text.contains("electric") ||
        text.contains("water") ||
        text.contains("utility")) {
      return "Bills";
    }

    return "General";
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
            colors: [
              Color(0xFF0F172A),
              Color(0xFF020617),
            ],
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
                  margin:
                  const EdgeInsets.symmetric(horizontal: 40),
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(20),
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
                  duration:
                  const Duration(milliseconds: 400),
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
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}