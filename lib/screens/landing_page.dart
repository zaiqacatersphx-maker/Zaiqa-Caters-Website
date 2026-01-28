import 'package:flutter/material.dart';
import 'package:meal_brand/widgets/nav_bar.dart';
import 'package:meal_brand/widgets/hero_section.dart';
import 'package:meal_brand/widgets/features_section.dart';
import 'package:meal_brand/widgets/menu_section.dart';
import 'package:meal_brand/widgets/how_it_works_section.dart';
// import 'package:meal_brand/widgets/newsletter_section.dart';
import 'package:meal_brand/widgets/footer.dart';
import 'package:meal_brand/widgets/mobile_drawer.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: const MobileDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const NavBar(),
            const HeroSection(),
            const FeaturesSection(),
            const MenuSection(),
            const HowItWorksSection(),
            // const NewsletterSection(),
            const Footer(),
          ],
        ),
      ),
    );
  }
}
