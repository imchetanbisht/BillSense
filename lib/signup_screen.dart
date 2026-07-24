import 'dart:ui';
import 'package:flutter/material.dart';
import 'main_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  double get _passwordStrengthProgress {
    int length = _passwordController.text.length;
    if (length == 0) return 0.0;
    if (length < 6) return 0.33;
    if (length < 10) return 0.66;
    return 1.0;
  }

  Color get _passwordStrengthColor {
    double progress = _passwordStrengthProgress;
    if (progress <= 0.33) return Colors.redAccent;
    if (progress <= 0.66) return Colors.orangeAccent;
    return Colors.greenAccent;
  }

  String get _passwordStrengthLabel {
    double progress = _passwordStrengthProgress;
    if (progress == 0) return "";
    if (progress <= 0.33) return "Weak Password";
    if (progress <= 0.66) return "Good Password";
    return "Strong Password";
  }

  void _handleSignup() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please fill in all fields"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Passwords do not match"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please agree to the Terms of Service"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: Stack(
        children: [
          // Ambient Glow
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: Color(0xFF6366F1)),
                          SizedBox(width: 6),
                          Text("Back", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: const [
                      Text(
                        "Create Account",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 24),
                    ],
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Join BillSense to automate bill scanning & AI savings insights",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),

                  const SizedBox(height: 28),

                  // Form Container
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                        ),
                        child: Column(
                          children: [
                            // Full Name Input
                            _glassTextField(
                              controller: _nameController,
                              hint: "Full Name",
                              icon: Icons.person_rounded,
                            ),

                            const SizedBox(height: 16),

                            // Email Input
                            _glassTextField(
                              controller: _emailController,
                              hint: "Email Address",
                              icon: Icons.email_rounded,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 16),

                            // Password Input
                            _glassTextField(
                              controller: _passwordController,
                              hint: "Password",
                              icon: Icons.lock_rounded,
                              isObscure: !_isPasswordVisible,
                              onChanged: (_) => setState(() {}),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  color: Colors.white54,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                                },
                              ),
                            ),

                            // Password Strength Bar
                            if (_passwordController.text.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _passwordStrengthLabel,
                                    style: TextStyle(
                                      color: _passwordStrengthColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _passwordStrengthProgress,
                                  color: _passwordStrengthColor,
                                  backgroundColor: Colors.white10,
                                  minHeight: 5,
                                ),
                              ),
                            ],

                            const SizedBox(height: 16),

                            // Confirm Password Input
                            _glassTextField(
                              controller: _confirmPasswordController,
                              hint: "Confirm Password",
                              icon: Icons.lock_clock_rounded,
                              isObscure: !_isPasswordVisible,
                            ),

                            const SizedBox(height: 16),

                            // Terms Checkbox
                            Row(
                              children: [
                                Checkbox(
                                  value: _agreedToTerms,
                                  activeColor: const Color(0xFF6366F1),
                                  side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                                  onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                                ),
                                const Expanded(
                                  child: Text(
                                    "I agree to the Terms of Service & Privacy Policy",
                                    style: TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // Submit Button
                            ElevatedButton(
                              onPressed: _isLoading ? null : _handleSignup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                minimumSize: const Size(double.infinity, 54),
                                elevation: 8,
                                shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                    )
                                  : const Text(
                                      "Create Account",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isObscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(icon, color: const Color(0xFF6366F1), size: 22),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
