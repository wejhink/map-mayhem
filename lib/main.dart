import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:map_mayhem/app/app.dart';
import 'package:provider/provider.dart';
import 'package:map_mayhem/core/services/geojson_service.dart';
import 'package:map_mayhem/core/services/map_service.dart';
import 'package:map_mayhem/core/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  final storageService = StorageService();
  await storageService.init();

  final mapService = MapService();
  await mapService.init();

  final geoJsonService = GeoJsonService();
  await geoJsonService.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<MapService>.value(value: mapService),
        Provider<GeoJsonService>.value(value: geoJsonService),
        // Add other providers here as needed
      ],
      child: const MapMayhemApp(),
    ),
  );
}
