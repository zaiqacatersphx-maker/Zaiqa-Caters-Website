import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: isMobile
          ? Column(
              children: [
                _FeatureItem(
                  icon: Icons.checklist,
                  title: "Choose Your Plan",
                  description: "Choose your plan, set and forget.",
                ),
                const SizedBox(height: 40),
                _FeatureItem(
                  icon: Icons.local_shipping_outlined,
                  title: "We Cook & Deliver",
                  description:
                      "We cook and deliver fresh meals to your doorstep.",
                ),
                const SizedBox(height: 40),
                _FeatureItem(
                  icon: Icons.soup_kitchen_outlined,
                  title: "Enjoy Healthy Meals",
                  description:
                      "Fresh, healthy, and delicious meals made with love.",
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _FeatureItem(
                    icon: Icons.checklist,
                    title: "Choose Your Plan",
                    description: "Choose your plan, set and forget.",
                  ),
                ),
                Expanded(
                  child: _FeatureItem(
                    icon: Icons.local_shipping_outlined,
                    title: "We Cook & Deliver",
                    description:
                        "We cook and deliver fresh meals to your doorstep.",
                  ),
                ),
                Expanded(
                  child: _FeatureItem(
                    icon: Icons.soup_kitchen_outlined,
                    title: "Enjoy Healthy Meals",
                    description:
                        "Fresh, healthy, and delicious meals made with love.",
                  ),
                ),
              ],
            ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 64, color: const Color(0xFF90D26D)), // Light Green
        const SizedBox(height: 20),
        Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            description,
            style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
