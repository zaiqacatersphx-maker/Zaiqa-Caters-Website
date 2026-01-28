import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 900;
    
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: Column(
        children: [
          Text(
            "How It Works",
            style: GoogleFonts.dmSans(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 60),
          isMobile 
            ? Column(
                children: [
                   _StepItem(step: "1", title: "Register on our platform", description: "Your account helps us know you better.", icon: Icons.assignment_outlined),
                   const SizedBox(height: 40),
                   _StepItem(step: "2", title: "Choose your plan", description: "Weekly menu is updated every week.", icon: Icons.person_outline),
                   const SizedBox(height: 40),
                   _StepItem(step: "3", title: "We cook fresh meals for you", description: "Freshly prepared meals made with quality ingredients.", icon: Icons.directions_car_outlined),
                   const SizedBox(height: 40),
                   _StepItem(step: "4", title: "Pick up or get it delivered", description: "Receive your meals at your doorstep or pick them up from our location.", icon: Icons.shopping_bag_outlined),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _StepItem(step: "1", title: "Register on our platform", description: "Your account helps us know you better.", icon: Icons.assignment_outlined)),
                  Expanded(child: _StepItem(step: "2", title: "Choose your plan", description: "Weekly menu is updated every week.", icon: Icons.person_outline)),
                  Expanded(child: _StepItem(step: "3", title: "We cook fresh meals for you", description: "Freshly prepared meals made with quality ingredients.", icon: Icons.directions_car_outlined)),
                  Expanded(child: _StepItem(step: "4", title: "Pick up or get it delivered", description: "Receive your meals at your doorstep or pick them up from our location.", icon: Icons.shopping_bag_outlined)),
                ],
              ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String step;
  final String title;
  final String description;
  final IconData icon;

  const _StepItem({required this.step, required this.title, required this.description, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8E9), // Light green circle/bg
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: const Color(0xFF2C5F2D)),
            ),
            // Step Number Badge (optional, visually implied in design via order, but explicit in text)
          ],
        ),
        const SizedBox(height: 20),
        Text(
          "Step $step. $title",
          style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            description,
            style: GoogleFonts.dmSans(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
