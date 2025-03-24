import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:map_mayhem/app/routes.dart';
import 'package:map_mayhem/core/services/audio_service.dart';
import 'package:map_mayhem/presentation/themes/app_colors.dart';
import 'package:provider/provider.dart';

/// The splash screen displayed when the app is launched.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late AudioService _audioService;

  @override
  void initState() {
    super.initState();

    // Get audio service
    _audioService = Provider.of<AudioService>(context, listen: false);

    // Play a sound effect when the splash screen appears
    _audioService.playButtonSound();

    // Show enable audio dialog for web platforms
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kIsWeb) {
        AudioService.showEnableAudioDialog(context);
      }
    });

    // Navigate to dashboard after a delay
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, AppRouter.dashboardRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      // Add a floating action button for web platforms to enable audio
      floatingActionButton: kIsWeb
          ? FloatingActionButton.extended(
              onPressed: () {
                _audioService.userHasInteracted();
                _audioService.playButtonSound();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Audio enabled!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.volume_up),
              label: const Text('Enable Audio'),
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
            )
          : null,
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
