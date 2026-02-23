import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'processing_screen.dart';
import 'history_screen.dart';
import 'insight_screen.dart';
import 'savings_screen.dart';
import 'tips_screen.dart';

import '../bill_service.dart';
import '../ocr_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {

  File? image;

  late AnimationController _iconController;
  late Animation<double> _iconScale;

  late AnimationController _laserController;

  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    /// ICON ANIMATION
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _iconScale = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: Curves.easeInOut,
      ),
    );

    /// LASER ANIMATION
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _iconController.dispose();
    _laserController.dispose();
    super.dispose();
  }

  /// ================= PICK IMAGE =================
  Future<void> pickImage(ImageSource source) async {

    try {

      final picked = await picker.pickImage(source: source);

      if (picked == null) return;

      final file = File(picked.path);

      if (!mounted) return;

      setState(() {
        image = file;
      });

    } catch (e) {
      debugPrint("Image pick error: $e");
    }
  }

  /// ================= BILL VALIDATION =================
  bool _isBillText(String text) {

    text = text.toLowerCase();

    List<String> keywords = [
      "total",
      "amount",
      "invoice",
      "gst",
      "tax",
      "bill",
      "qty",
      "price",
      "subtotal",
      "cash",
      "grand",
      "payment"
    ];

    for (var word in keywords) {
      if (text.contains(word)) return true;
    }

    return false;
  }

  /// ================= START SCAN =================
  void startScan() async {

    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a bill first"),
        ),
      );
      return;
    }

    String text = await OCRService.extractText(image!);

    bool isBill = _isBillText(text);

    if (!isBill) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("This is not a bill image"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProcessingScreen(image: image!),
      ),
    ).then((_) => setState(() {}));
  }

  /// ================= OPEN FEATURE =================
  void openScreen(Widget screen) {

    if (!BillService.hasData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Scan at least one bill first"),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// HEADER
              Row(
                children:[

                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: Color(0xFF6366F1),
                    child: Icon(Icons.receipt_long,
                        color: Colors.white),
                  ),

                  const SizedBox(width: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [

                      Text(
                        "BillSense AI",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        "Smart Expense Tracker",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      )
                    ],
                  )
                ],
              ),

              const SizedBox(height: 30),

              /// SCAN CARD
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.06),
                      Colors.white.withOpacity(0.02),
                    ],
                  ),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.08)),
                ),

                child: Column(
                  children: [

                    /// ANIMATED ICON
                    ScaleTransition(
                      scale: _iconScale,
                      child: _scannerIcon(),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      "Scan Your Bill",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [

                        Expanded(
                          child: premiumButton(
                              Icons.camera_alt,
                              "Camera",
                                  () => pickImage(ImageSource.camera)),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: premiumButton(
                              Icons.upload_file,
                              "Upload",
                                  () => pickImage(ImageSource.gallery)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    /// IMAGE + LASER
                    if (image != null)
                      ClipRRect(
                        borderRadius:
                        BorderRadius.circular(14),
                        child: Stack(
                          children: [

                            Image.file(
                              image!,
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),

                            AnimatedBuilder(
                              animation: _laserController,
                              builder: (_, __) {

                                return Positioned(
                                  top: _laserController.value * 160,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 3,
                                    decoration: BoxDecoration(
                                      gradient:
                                      const LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.greenAccent,
                                          Colors.transparent,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.greenAccent
                                              .withOpacity(0.7),
                                          blurRadius: 8,
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: startScan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFF6366F1),
                        minimumSize:
                        const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Start AI Scan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Features",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [

                  Expanded(
                    child: featureCard(
                      "Insights",
                      "AI spending analysis",
                      Icons.analytics,
                          () => openScreen(const InsightScreen()),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: featureCard(
                      "Savings",
                      "Future predictions",
                      Icons.savings,
                          () => openScreen(const SavingsScreen()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [

                  Expanded(
                    child: featureCard(
                      "AI Tips",
                      "Smart suggestions",
                      Icons.lightbulb,
                          () => openScreen(const TipsScreen()),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: featureCard(
                      "History",
                      "All scanned bills",
                      Icons.history,
                          () => openScreen(const HistoryScreen()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scannerIcon() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF6366F1).withOpacity(0.15),
      ),
      child: const Icon(
        Icons.document_scanner,
        size: 45,
        color: Color(0xFF6366F1),
      ),
    );
  }

  Widget premiumButton(
      IconData icon,
      String text,
      VoidCallback onTap,
      ) {

    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding:
        const EdgeInsets.symmetric(vertical: 14),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),

        child: Column(
          children: [

            Icon(icon, color: Colors.black),

            const SizedBox(height: 5),

            Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget featureCard(
      String title,
      String subtitle,
      IconData icon,
      VoidCallback onTap,
      ) {

    return GestureDetector(
      onTap: onTap,

      child: Container(
        height: 130,
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            Icon(icon,
                color: const Color(0xFF6366F1),
                size: 26),

            const Spacer(),

            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            )
          ],
        ),
      ),
    );
  }
}