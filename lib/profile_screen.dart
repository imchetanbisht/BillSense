import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../bill_service.dart';
import '../login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {

  File? profileImage;

  late final AnimationController _controller;
  late final Animation<double> _fade;

  final user = FirebaseAuth.instance.currentUser;

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// ================= STATS =================

  int get totalScans => BillService.bills.length;

  double get totalAmount {
    return BillService.bills.fold(
      0.0,
          (sum, bill) => sum + bill.amount,
    );
  }

  double get totalSaved => totalAmount * 0.1;

  int get score {

    if (totalScans == 0) return 0;

    double avg = totalAmount / totalScans;

    int calculated =
    (100 - (avg / 50)).clamp(0, 100).toInt();

    return calculated;
  }

  /// ================= PICK IMAGE =================

  Future pickProfileImage() async {

    final picked =
    await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {
      setState(() {
        profileImage = File(picked.path);
      });
    }
  }

  /// ================= LOGOUT CONFIRMATION =================

  void showLogoutDialog() {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {

        return AlertDialog(
          backgroundColor: const Color(0xFF020617),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          title: const Text(
            "Logout",
            style: TextStyle(color: Colors.white),
          ),

          content: const Text(
            "Are you sure you want to logout?",
            style: TextStyle(color: Colors.white70),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white54),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () async {

                Navigator.pop(context);

                await FirebaseAuth.instance.signOut();

                if (!mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                      (route) => false,
                );
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void openSettings() {}
  void openHelp() {}
  void openAbout() {}

  @override
  Widget build(BuildContext context) {

    String name = user?.displayName ?? "User";
    String email = user?.email ?? "No Email";

    return Scaffold(
      backgroundColor: Colors.transparent,

      body: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [

                  /// PROFILE HEADER
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(22),
                    ),

                    child: Column(
                      children: [

                        GestureDetector(
                          onTap: pickProfileImage,
                          child: CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.indigo,
                            backgroundImage: profileImage != null
                                ? FileImage(profileImage!)
                                : null,
                            child: profileImage == null
                                ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            )
                                : null,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          email,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// STATS
                  Row(
                    children: [

                      Expanded(
                        child: statCard(
                          totalScans.toString(),
                          "Scans",
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: statCard(
                          "₹${totalSaved.toStringAsFixed(0)}",
                          "Saved",
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: statCard(
                          "$score%",
                          "Score",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  profileOption(Icons.settings, "Settings", openSettings),
                  profileOption(Icons.help_outline, "Help & Support", openHelp),
                  profileOption(Icons.info_outline, "About App", openAbout),

                  /// ✅ LOGOUT BUTTON FIXED
                  profileOption(Icons.logout, "Logout", showLogoutDialog),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget statCard(String value, String title) {

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),

      child: Column(
        children: [

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget profileOption(
      IconData icon,
      String title,
      VoidCallback onTap,
      ) {

    return GestureDetector(
      onTap: onTap,

      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),

        child: Row(
          children: [

            Icon(icon, color: Colors.white),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white38,
              size: 16,
            )
          ],
        ),
      ),
    );
  }
}