import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meal_brand/widgets/auth_dialog.dart';
import 'package:meal_brand/screens/plans_page.dart';
import 'package:meal_brand/screens/friday_specials_page.dart';
import 'package:meal_brand/screens/admin_dashboard.dart';
import 'package:url_launcher/url_launcher.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

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
            ListTile(
              leading: const Icon(Icons.groups, color: Color(0xFF2C5F2D)),
              title: const Text("Join WhatsApp Group"),
              subtitle: const Text("Click to join"),
              onTap: () async {
                final Uri launchUri = Uri.parse(
                  'https://chat.whatsapp.com/BwOe1KFwlT5FXXMU5f1eAK?mode=gi_t',
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 60,
                height: 20,
                child: OverflowBox(
                  maxWidth: 100,
                  maxHeight: 100,
                  child: Image.asset(
                    "assets/images/logo.png",
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              // Image.asset("assets/images/logo.png", width: 60, height: 60),
              const SizedBox(width: 10),
              Text(
                "𝓩𝓪𝓲𝓺𝓪 𝓒𝓪𝓽𝓮𝓻𝓮𝓻𝓼",
                style: GoogleFonts.notoKufiArabic(
                  // fontWeight: FontWeight.bold,
                  // fontStyle: FontStyle.italic,
                  fontSize: 32,
                  color: const Color(0xFF2C5F2D),
                ),
              ),
            ],
          ),
          if (MediaQuery.of(context).size.width > 800)
            Row(
              children: [
                _NavLink(
                  title: "Home",
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/', (route) => false),
                ),
                const SizedBox(width: 30),
                _NavLink(
                  title: "Plans",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PlansPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 30),
                _NavLink(
                  title: "Friday Specials",
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FridaySpecialsPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 30),
                _NavLink(
                  title: "Contact",
                  onTap: () => _showContactDialog(context),
                ),
                const SizedBox(width: 30),
                StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, authSnapshot) {
                    if (authSnapshot.hasData && authSnapshot.data != null) {
                      // User is logged in, fetch their profile for name
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

                          return GestureDetector(
                            onLongPress: () => _handleAdminAccess(context),
                            child: Row(
                              children: [
                                Text(
                                  "Hi, $displayName!",
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2C5F2D),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(
                                    Icons.logout,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    FirebaseAuth.instance.signOut();
                                    Navigator.of(
                                      context,
                                    ).pushNamedAndRemoveUntil(
                                      '/',
                                      (route) => false,
                                    );
                                  },
                                  tooltip: "Log Out",
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                    // User is not logged in
                    return GestureDetector(
                      onLongPress: () => _handleAdminAccess(context),
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const AuthDialog(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFFFFC107,
                          ), // Orange/Yellow
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          "Register",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ],
            )
          else
            IconButton(
              icon: const Icon(Icons.menu, color: Color(0xFF2C5F2D)),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  const _NavLink({required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onTap ?? () {},
        child: Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
