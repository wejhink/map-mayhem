import 'package:flutter/material.dart';
import 'package:map_mayhem/app/routes.dart';
import 'package:map_mayhem/presentation/themes/app_theme.dart';

/// The main application widget for Map Mayhem.
class MapMayhemApp extends StatelessWidget {
  const MapMayhemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map Mayhem',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.splashRoute,
    );
  }
}
