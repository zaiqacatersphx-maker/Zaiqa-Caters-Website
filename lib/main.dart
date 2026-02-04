import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/landing_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDpE4LgzQ3fCfhluxNb-XjfJCdu7oWBO2I",
      authDomain: "meal-prep-b6461.firebaseapp.com",
      databaseURL: "https://meal-prep-b6461-default-rtdb.firebaseio.com",
      projectId: "meal-prep-b6461",
      storageBucket: "meal-prep-b6461.firebasestorage.app",
      messagingSenderId: "1033470138860",
      appId: "1:1033470138860:web:50f7f6efd549e004dd48c9",
      measurementId: "G-7FBQYXSBEQ",
    ),
  );
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
