import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sikatu/screens/login_screen.dart';
import 'package:sikatu/screens/main_screen.dart';
import 'package:sikatu/theme/app_colors.dart';
import 'package:sikatu/widgets/primary_button.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- LOGIKA DARK MODE ---
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final titleColor = isDark ? Colors.white : AppColors.darkText;
    final subTitleColor = isDark ? Colors.grey[300] : AppColors.lightText;

    if (_isChecking) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Gambar Ilustrasi
              Image.asset(
                'assets/images/splash_illustration.jpg',
                height: MediaQuery.of(context).size.height * 0.35,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.35,
                    alignment: Alignment.center,
                    child: Icon(Icons.image_not_supported, size: 50, color: subTitleColor),
                  );
                },
              ),
              const Spacer(flex: 1),

              // Teks Headline
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                    color: titleColor, // Warna judul dinamis
                    fontFamily: 'Roboto',
                  ),
                  children: const [
                    TextSpan(text: 'Track, Manage, and\nMaster '),
                    TextSpan(
                      text: 'Your Tasks',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'All your tasks, organized and ready.\nLet\'s get to it!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: subTitleColor, // Warna subjudul dinamis
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 2),

              PrimaryButton(
                text: 'Lets Start',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}