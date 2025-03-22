import 'dart:async';
import 'package:flutter/material.dart';
import 'package:map_mayhem/app/routes.dart';
import 'package:map_mayhem/presentation/themes/app_colors.dart';

/// The splash screen displayed when the app is launched.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to dashboard after a delay
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, AppRouter.dashboardRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.public,
                size: 100,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            // App name
            const Text(
              'Map Mayhem',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // App tagline
            const Text(
              'Master world geography through play',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
