import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/landing_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAtjvDTdI_f7g6TTGqI9B11gE01KIP0m1g",
      authDomain: "zaiqacatererswebsite.firebaseapp.com",
      projectId: "zaiqacatererswebsite",
      storageBucket: "zaiqacatererswebsite.firebasestorage.app",
      messagingSenderId: "999360471182",
      appId: "1:999360471182:web:4191ec1ffc6f58831ae9df",
      measurementId: "G-G5DWY5KJ65",
    ),
  ); // TODO: Add Firebase Configuration
  runApp(const ZestAndZenApp());
}

class ZestAndZenApp extends StatelessWidget {
  const ZestAndZenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zaiqa Caterers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(
            0xFF90D26D,
          ), // Light warm green from screenshot
          primary: const Color(0xFF2C5F2D), // Darker green for contrast
          secondary: const Color(0xFFFFC107), // Yellow/Orange accent
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.dmSansTextTheme(), // Clean modern sans
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
      ),
      home: const LandingPage(),
    );
  }
}
