import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_brand/screens/plans_page.dart';
import 'package:meal_brand/widgets/auth_dialog.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 500),
      child: isMobile
          ? Column(
              children: [
                _ImageContent(isMobile: true),
                _TextContent(isMobile: true),
              ],
            )
          : Row(
              children: [
                Expanded(child: _ImageContent(isMobile: false)),
                Expanded(child: _TextContent(isMobile: false)),
              ],
            ),
    );
  }
}

class _ImageContent extends StatelessWidget {
  final bool isMobile;
  const _ImageContent({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isMobile ? 300 : 500, // Reduced height for mobile
      decoration: BoxDecoration(
        color: Colors.grey[200], // Lighter background for contain
        image: DecorationImage(
          image: const AssetImage("assets/images/meals.png"),
          fit: isMobile ? BoxFit.contain : BoxFit.cover, // Contain for mobile
        ),
      ),
      child: Container(
        color: Colors.black.withValues(
          alpha: isMobile ? 0.02 : 0.1,
        ), // Subtle overlay
      ),
    );
  }
}

class _TextContent extends StatelessWidget {
  final bool isMobile;
  const _TextContent({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      color: const Color(0xFF1E1E1E), // Dark background from screenshot
      padding: const EdgeInsets.all(60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Fresh Halal Home Cooked Meals",
            style: GoogleFonts.dmSerifDisplay(
              // Serif for heading
              fontSize: isMobile ? 36 : 48,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Have a look at our menu and start your meal journey with us.",
            style: GoogleFonts.dmSans(
              fontSize: 16,
              color: Colors.grey[400],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PlansPage()),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (_) => const AuthDialog(isSignUp: true),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              "Sign Up Now",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
