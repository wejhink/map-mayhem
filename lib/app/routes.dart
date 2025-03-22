import 'package:flutter/material.dart';
import 'package:map_mayhem/features/dashboard/screens/dashboard_screen.dart';
import 'package:map_mayhem/features/game/screens/game_screen.dart';
import 'package:map_mayhem/features/settings/screens/settings_screen.dart';
import 'package:map_mayhem/features/splash/screens/splash_screen.dart';

/// Handles the routing configuration for the app.
class AppRouter {
  // Route names
  static const String splashRoute = '/';
  static const String dashboardRoute = '/dashboard';
  static const String gameRoute = '/game';
  static const String settingsRoute = '/settings';

  /// Generates routes based on route name.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashRoute:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
      case dashboardRoute:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        );
      case gameRoute:
        return MaterialPageRoute(
          builder: (_) => const GameScreen(),
        );
      case settingsRoute:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );
      default:
        // If the route is not found, return to splash screen
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
    }
  }
}
