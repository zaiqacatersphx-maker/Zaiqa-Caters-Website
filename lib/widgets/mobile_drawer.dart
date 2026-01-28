import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meal_brand/screens/admin_dashboard.dart';
import 'package:meal_brand/screens/friday_specials_page.dart';
import 'package:meal_brand/screens/plans_page.dart';
import 'package:meal_brand/widgets/auth_dialog.dart';

import 'package:url_launcher/url_launcher.dart';

class MobileDrawer extends StatelessWidget {
  const MobileDrawer({super.key});

  Future<void> _showContactDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Contact Us"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone, color: Color(0xFF2C5F2D)),
              title: const Text("Call Us"),
              subtitle: const Text("+1 (602) 489-2987"),
              onTap: () async {
                final Uri launchUri = Uri(scheme: 'tel', path: '+16024892987');
                if (await canLaunchUrl(launchUri)) {
                  await launchUrl(launchUri);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Color(0xFF2C5F2D)),
              title: const Text("Email Us"),
              subtitle: const Text("zaiqacatersphx@gmail.com"),
              onTap: () async {
                final Uri launchUri = Uri(
                  scheme: 'mailto',
                  path: 'zaiqacatersphx@gmail.com',
                );
                if (await canLaunchUrl(launchUri)) {
                  await launchUrl(launchUri);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Close",
              style: TextStyle(color: Color(0xFF2C5F2D)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAdminAccess(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showDialog(context: context, builder: (_) => const AuthDialog()).then((
        _,
      ) async {
        // After returning from dialog, check if user logged in
        final newUser = FirebaseAuth.instance.currentUser;
        if (newUser != null) {
          _checkAdminAndNavigate(context, newUser);
        }
      });
    } else {
      _checkAdminAndNavigate(context, user);
    }
  }

  Future<void> _checkAdminAndNavigate(BuildContext context, User user) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        // Check for 'isAdmin' field
        if (data['isAdmin'] == true) {
          if (context.mounted) {
            Navigator.pop(context); // Close drawer
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AdminDashboard()),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Access Denied: Admins only.")),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Admin check error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF2C5F2D)),
              child: Center(
                child: Text(
                  "Zaiqa Caterers",
                  style: GoogleFonts.dmSerifDisplay(
                    color: Colors.white,
                    fontSize: 32,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Color(0xFF2C5F2D)),
              title: Text(
                "Home",
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.restaurant_menu,
                color: Color(0xFF2C5F2D),
              ),
              title: Text(
                "Plans",
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PlansPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.local_offer, color: Color(0xFF2C5F2D)),
              title: Text(
                "Friday Specials",
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FridaySpecialsPage(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.contact_mail, color: Color(0xFF2C5F2D)),
              title: Text(
                "Contact",
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showContactDialog(context);
              },
            ),
            const Spacer(),
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, authSnapshot) {
                if (authSnapshot.hasData && authSnapshot.data != null) {
                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('customers')
                        .doc(authSnapshot.data!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      String displayName = "Friend";
                      if (snapshot.hasData &&
                          snapshot.data != null &&
                          snapshot.data!.exists) {
                        final data =
                            snapshot.data!.data() as Map<String, dynamic>;
                        displayName = data['firstName'] ?? 'Friend';
                      }

                      return Column(
                        children: [
                          const Divider(),
                          GestureDetector(
                            onLongPress: () => _handleAdminAccess(context),
                            child: ListTile(
                              leading: const Icon(
                                Icons.person,
                                color: Color(0xFF2C5F2D),
                              ),
                              title: Text(
                                "Hi, $displayName!",
                                style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2C5F2D),
                                ),
                              ),
                            ),
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.logout,
                              color: Colors.grey,
                            ),
                            title: Text(
                              "Log Out",
                              style: GoogleFonts.dmSans(color: Colors.grey),
                            ),
                            onTap: () {
                              FirebaseAuth.instance.signOut();
                              Navigator.pop(context);
                              Navigator.of(
                                context,
                              ).pushNamedAndRemoveUntil('/', (route) => false);
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: GestureDetector(
                      onLongPress: () => _handleAdminAccess(context),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (_) => const AuthDialog(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC107),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
