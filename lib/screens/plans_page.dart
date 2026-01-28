import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meal_brand/widgets/nav_bar.dart';
import 'package:meal_brand/widgets/footer.dart';
import 'package:meal_brand/widgets/auth_dialog.dart';
import 'package:meal_brand/widgets/mobile_drawer.dart';

class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  String? _currentPlan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkCurrentPlan();
  }

  Future<void> _checkCurrentPlan() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('customers')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          var data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('plan') && data['plan'] != 'no') {
            setState(() {
              _currentPlan = data['plan'];
            });
          }
        }
      } catch (e) {
        debugPrint("Error fetching plan: $e");
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectPlan(BuildContext context, String planName) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (_currentPlan != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You already have an active plan!")),
        );
        return;
      }

      // User is logged in, save plan
      try {
        await FirebaseFirestore.instance
            .collection('customers')
            .doc(user.uid)
            .update({'plan': planName});

        setState(() {
          _currentPlan = planName;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Successfully subscribed to $planName!")),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error saving plan: $e")));
        }
      }
    } else {
      // User not logged in, prompt to sign up
      showDialog(
        context: context,
        builder: (_) => const AuthDialog(isSignUp: true),
      ).then((_) => _checkCurrentPlan()); // Re-check after potential login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: const MobileDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2C5F2D)),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  const NavBar(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 50,
                      horizontal: 20,
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Choose the Plan That Fits Your Life",
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 36,
                            color: const Color(0xFF2C5F2D),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Flexible. Delicious. Delivered.",
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 60),
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('weekly_menu')
                              .doc('current_week')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Text(
                                "Error loading menu: ${snapshot.error}",
                              );
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator(
                                color: Color(0xFF2C5F2D),
                              );
                            }

                            Map<String, String> zenMenu = {
                              "Mon": "Loading...",
                              "Tue": "Loading...",
                              "Wed": "Loading...",
                              "Thu": "Loading...",
                              "Fri": "Loading...",
                              "Sat": "Loading...",
                              "Sun": "Loading...",
                            };

                            if (snapshot.hasData &&
                                snapshot.data != null &&
                                snapshot.data!.exists) {
                              final data =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              if (data['zen'] != null) {
                                zenMenu = Map<String, String>.from(
                                  data['zen'] as Map,
                                );
                              }
                            }

                            return Wrap(
                              spacing: 40,
                              runSpacing: 40,
                              alignment: WrapAlignment.center,
                              children: [
                                _PlanCard(
                                  title: "The Full Zen",
                                  price: "\$220/15 days",
                                  days: "Mon - Sun ",
                                  description:
                                      "All meals are Halal and made with fresh ingredients. Beef is not used in any of the meals.",
                                  menu: zenMenu,
                                  color: const Color(0xFFE0F2F1), // Light Teal
                                  onSelect: () =>
                                      _selectPlan(context, "The Full Zen"),
                                  isCurrentPlan: _currentPlan == "The Full Zen",
                                  hasActivePlan: _currentPlan != null,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const Footer(),
                ],
              ),
            ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String days;
  final String description;
  final Map<String, String> menu;
  final Color color;
  final VoidCallback onSelect;
  final bool isCurrentPlan;
  final bool hasActivePlan;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.days,
    required this.description,
    required this.menu,
    required this.color,
    required this.onSelect,
    this.isCurrentPlan = false,
    this.hasActivePlan = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrentPlan
              ? const Color(0xFF2C5F2D)
              : Colors.black.withOpacity(0.05),
          width: isCurrentPlan ? 3 : 1,
        ),
      ),
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C5F2D),
                  ),
                ),
              ),
              if (isCurrentPlan)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF2C5F2D),
                  size: 30,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            price,
            style: GoogleFonts.dmSans(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            days,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            style: GoogleFonts.dmSans(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          Divider(color: Colors.black12),
          const SizedBox(height: 20),
          Text(
            "This Week's Menu:",
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          const SizedBox(height: 15),
          ...['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
            final item = menu[day];
            if (item == null) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 50,
                    child: Text(
                      "$day:",
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C5F2D),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.dmSans(color: Colors.black87),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 40),
          Center(
            child: ElevatedButton(
              onPressed: hasActivePlan
                  ? null
                  : onSelect, // Disable if ANY plan is active
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C5F2D),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[400],
                disabledForegroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                isCurrentPlan
                    ? "Current Plan"
                    : (hasActivePlan ? "Plan Active" : "Choose Plan"),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
