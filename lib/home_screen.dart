import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'processing_screen.dart';
import 'history_screen.dart';
import 'insight_screen.dart';
import 'savings_screen.dart';
import 'tips_screen.dart';
import 'login_screen.dart';

import '../bill_service.dart';
import '../ocr_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  File? image;

  late AnimationController _pulseController;
  late Animation<double> _pulseScale;

  late AnimationController _laserController;

  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _laserController.dispose();
    super.dispose();
  }

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

  bool _isBillText(String text) {
    text = text.toLowerCase();
    List<String> keywords = [
      "total", "amount", "invoice", "gst", "tax", "bill", "qty", "price", "subtotal", "cash", "grand", "payment"
    ];
    for (var word in keywords) {
      if (text.contains(word)) return true;
    }
    return false;
  }

  void startScan() async {
    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please select a bill image first"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    String text = await OCRService.extractText(image!);
    bool isBill = _isBillText(text);

    if (!isBill) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("This is not a recognized bill image"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProcessingScreen(image: image!),
      ),
    ).then((_) => setState(() {}));
  }

  void openScreen(Widget screen) {
    if (!BillService.hasData) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Scan at least one bill first"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      body: Stack(
        children: [
          // Background Ambient Glow
          Positioned(
            top: -100,
            left: -80,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6366F1).withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header Bar
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "BillSense AI",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Smart Expense Analytics",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Action Buttons (Bell & Logout)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.notifications_rounded, color: Colors.white70, size: 20),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                                (route) => false,
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Hero Scanner Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Column(
                          children: [
                            // Double Pulse Icon
                            ScaleTransition(
                              scale: _pulseScale,
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF6366F1).withValues(alpha: 0.18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                                      blurRadius: 20,
                                    )
                                  ],
                                ),
                                child: const Icon(
                                  Icons.document_scanner_rounded,
                                  size: 44,
                                  color: Color(0xFF6366F1),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            const Text(
                              "Scan Receipt & Extract Data",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            const Text(
                              "Capture or upload a bill image to auto-detect amounts & generate AI tips",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white54, fontSize: 12),
                            ),

                            const SizedBox(height: 20),

                            // Camera / Upload Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: _actionButton(
                                    Icons.camera_alt_rounded,
                                    "Camera",
                                    () => pickImage(ImageSource.camera),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _actionButton(
                                    Icons.photo_library_rounded,
                                    "Gallery",
                                    () => pickImage(ImageSource.gallery),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // Selected Image Preview with Laser Line
                            if (image != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
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
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.greenAccent,
                                                  Colors.transparent,
                                                ],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.greenAccent.withValues(alpha: 0.8),
                                                  blurRadius: 10,
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

                            if (image != null) const SizedBox(height: 16),

                            // Start Scan CTA Button
                            ElevatedButton.icon(
                              onPressed: startScan,
                              icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                              label: const Text(
                                "Start AI Scan Pipeline",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                minimumSize: const Size(double.infinity, 52),
                                elevation: 6,
                                shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Analytics Summary Metrics Row
                  const Text(
                    "Analytics Summary",
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
                        child: _statCard("Total Spent", "₹${BillService.bills.fold(0.0, (s, b) => s + b.amount).toInt()}", "+14% vs last mo", Icons.wallet, const Color(0xFF6366F1)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _statCard("AI Savings", "₹${(BillService.bills.fold(0.0, (s, b) => s + b.amount) * 0.22).toInt()}", "22% optimized", Icons.eco, Colors.greenAccent),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Interactive 2x2 Feature Grid
                  const Text(
                    "Core Features",
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
                        child: _featureCard("Insights", "AI spending analysis", Icons.analytics_rounded, const Color(0xFF6366F1), () => openScreen(const InsightScreen())),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _featureCard("Savings", "Future predictions", Icons.savings_rounded, Colors.greenAccent, () => openScreen(const SavingsScreen())),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _featureCard("AI Tips", "Smart suggestions", Icons.lightbulb_rounded, Colors.amberAccent, () => openScreen(const TipsScreen())),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _featureCard("History", "All scanned bills", Icons.history_rounded, Colors.purpleAccent, () => openScreen(const HistoryScreen())),
                      ),
                    ],
                  ),

                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
            )
          ],
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          Text(subtitle, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _featureCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 125,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 26),
            const Spacer(),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}