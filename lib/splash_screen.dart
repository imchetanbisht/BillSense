import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.8, end: 1.25).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _logoController.forward();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: Stack(
        children: [
          // Ambient Radial Mesh Background Glows
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return ZStackMesh(glowScale: _glowAnimation.value);
            },
          ),

          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hero 3D Logo Assembly
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer Halo Ring
                        AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (_, __) {
                            return Container(
                              width: 140 * _glowAnimation.value,
                              height: 140 * _glowAnimation.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  width: 2,
                                ),
                              ),
                            );
                          },
                        ),

                        // Main Glowing Circle
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.6),
                                blurRadius: 30,
                                spreadRadius: 4,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            size: 54,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Typography & Subtitle Slide Transition
                  SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: const [
                        Text(
                          "BillSense AI",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),

                        SizedBox(height: 8),

                        Text(
                          "Smart Expense Analytics & OCR Scanner",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ZStackMesh extends StatelessWidget {
  final double glowScale;
  const ZStackMesh({super.key, required this.glowScale});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -60,
          left: -40,
          child: Container(
            width: 320 * glowScale,
            height: 320 * glowScale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF6366F1).withValues(alpha: 0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: -40,
          right: -40,
          child: Container(
            width: 300 * glowScale,
            height: 300 * glowScale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF06B6D4).withValues(alpha: 0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
