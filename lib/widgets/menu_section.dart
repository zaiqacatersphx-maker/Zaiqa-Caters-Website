import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_brand/screens/plans_page.dart';

class MenuSection extends StatelessWidget {
  const MenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9F9F9),
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          // We might want a header here, but the design shows just the cards seamlessly or maybe this is a subsection.
          // Let's add the cards in a scrollable view.
          SizedBox(
            height: 480, // Height for card + padding
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              children: const [
                _MenuCard(
                  title: "Achari Chicken",
                  description:
                      "Tender chicken slow-cooked in bold Indian pickling spices for a tangy, spicy, irresistibly aromatic bite.",
                  imageUrl:
                      "https://images.pexels.com/photos/19725458/pexels-photo-19725458.jpeg",
                  bgColor: Colors.white,
                ),
                SizedBox(width: 30),
                _MenuCard(
                  title: "Red Chicken",
                  description:
                      "Juicy chicken cooked in a fiery red spice blend, rich, bold, and full of flavor.",
                  imageUrl:
                      "https://images.pexels.com/photos/7353380/pexels-photo-7353380.jpeg",
                  bgColor: Color(0xFFFFF3E0), // Light orange bg for card
                ),
                SizedBox(width: 30),
                _MenuCard(
                  title: "Mandi",
                  description:
                      "Tender, smoky chicken paired with aromatic mandi rice and traditional Arabian flavors.",
                  imageUrl:
                      "https://images.pexels.com/photos/7426867/pexels-photo-7426867.jpeg",
                  bgColor: Color(0xFFE0F2F1), // Light teal
                ),
                SizedBox(width: 30),
                _MenuCard(
                  title: "Paneer Butter Masala",
                  description:
                      "Soft paneer cubes in a rich, creamy tomato-butter gravy with mild spices.",
                  imageUrl:
                      "https://images.pexels.com/photos/12737805/pexels-photo-12737805.jpeg",
                  bgColor: Colors.white,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PlansPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C5F2D), // Green
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              "VIEW MENU",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final Color? bgColor;

  const _MenuCard({
    required this.title,
    required this.description,
    required this.imageUrl,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
