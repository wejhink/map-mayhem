import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

/// A class representing a country from GeoJSON data.
class GeoJsonCountry {
  final String? id;
  final String? name;
  final Map<String, dynamic> geometry;
  final Map<String, dynamic>? properties;

  GeoJsonCountry({
    this.id,
    this.name,
    required this.geometry,
    this.properties,
  });
}

/// Service for handling GeoJSON map data.
class GeoJsonService {
  /// Map of country features by ID for quick lookup
  Map<String, GeoJsonCountry> _countriesById = {};

  /// Map of country features by name for quick lookup
  Map<String, GeoJsonCountry> _countriesByName = {};

  /// Initialize the GeoJSON service.
  Future<void> init() async {
    await _loadGeoJson();
  }

  /// Load GeoJSON data from the assets.
  Future<void> _loadGeoJson() async {
    try {
      // Load the GeoJSON file from assets
      final String jsonString = await rootBundle.loadString('assets/maps/worldmap.geojson');

      // Parse the GeoJSON manually
      final Map<String, dynamic> geoJson = jsonDecode(jsonString);
      final List<dynamic> features = geoJson['features'] as List<dynamic>;

      // Create lookup maps
      _countriesById = {};
      _countriesByName = {};

      // Process all features (countries)
      for (var feature in features) {
        final Map<String, dynamic> featureMap = feature as Map<String, dynamic>;
        final String? id = featureMap['id'] as String?;
        final Map<String, dynamic>? properties = featureMap['properties'] as Map<String, dynamic>?;
        final String? name = properties?['name'] as String?;
        final Map<String, dynamic> geometry = featureMap['geometry'] as Map<String, dynamic>;
        final String geometryType = geometry['type'] as String;

        if (geometryType == 'Polygon' || geometryType == 'MultiPolygon') {
          final GeoJsonCountry country = GeoJsonCountry(
            id: id,
            name: name,
            geometry: geometry,
            properties: properties,
          );

          if (id != null) {
            _countriesById[id] = country;
          }

          if (name != null) {
            _countriesByName[name] = country;
          }
        }
      }
    } catch (e) {
      // Log the error using the logger package
      final logger = Logger();
      logger.e('Error loading GeoJSON: $e');

      // Initialize with empty data
      _countriesById = {};
      _countriesByName = {};
    }
  }

  /// Get a country feature by ID.
  GeoJsonCountry? getCountryFeatureById(String id) {
    return _countriesById[id];
  }

  /// Get a country feature by name.
  GeoJsonCountry? getCountryFeatureByName(String name) {
    return _countriesByName[name];
  }

  /// Get all country features.
  List<GeoJsonCountry> getAllCountryFeatures() {
    return _countriesById.values.toList();
  }

  /// Check if a point is inside a country.
  ///
  /// Returns the country ID if the point is inside a country, null otherwise.
  String? getCountryIdAtPoint(double latitude, double longitude) {
    for (var entry in _countriesById.entries) {
      if (_isPointInCountry(entry.value, latitude, longitude)) {
        return entry.key;
      }
    }
    return null;
  }

  /// Check if a point is inside a country.
  bool _isPointInCountry(GeoJsonCountry country, double latitude, double longitude) {
    final Map<String, dynamic> geometry = country.geometry;
    final String geometryType = geometry['type'] as String;

    if (geometryType == 'Polygon') {
      final List<dynamic> coordinates = geometry['coordinates'] as List<dynamic>;
      // Use the first ring (outer ring) of the polygon
      final List<dynamic> ring = coordinates[0] as List<dynamic>;
      return _isPointInPolygon(ring, latitude, longitude);
    } else if (geometryType == 'MultiPolygon') {
      final List<dynamic> polygons = geometry['coordinates'] as List<dynamic>;
      // Check all polygons in the MultiPolygon
      for (var polygon in polygons) {
        // Use the first ring (outer ring) of each polygon
        final List<dynamic> ring = polygon[0] as List<dynamic>;
        if (_isPointInPolygon(ring, latitude, longitude)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Check if a point is inside a polygon using the ray casting algorithm.
  bool _isPointInPolygon(List<dynamic> ring, double latitude, double longitude) {
    // Ray casting algorithm
    bool isInside = false;

    for (int i = 0, j = ring.length - 1; i < ring.length; j = i++) {
      final List<dynamic> pointI = ring[i] as List<dynamic>;
      final List<dynamic> pointJ = ring[j] as List<dynamic>;

      final double pointILng = pointI[0] as double;
      final double pointILat = pointI[1] as double;
      final double pointJLng = pointJ[0] as double;
      final double pointJLat = pointJ[1] as double;

      final intersect = ((pointILat > latitude) != (pointJLat > latitude)) &&
          (longitude < (pointJLng - pointILng) * (latitude - pointILat) / (pointJLat - pointILat) + pointILng);

      if (intersect) isInside = !isInside;
    }

    return isInside;
  }

  /// Get the bounds of a country feature.
  Map<String, double> getCountryBounds(String countryId) {
    final country = _countriesById[countryId];
    if (country == null) {
      return {
        'minLat': 0,
        'maxLat': 0,
        'minLng': 0,
        'maxLng': 0,
      };
    }

    double minLat = 90;
    double maxLat = -90;
    double minLng = 180;
    double maxLng = -180;

    final Map<String, dynamic> geometry = country.geometry;
    final String geometryType = geometry['type'] as String;

    if (geometryType == 'Polygon') {
      final List<dynamic> coordinates = geometry['coordinates'] as List<dynamic>;
      final bounds = _calculateBounds(coordinates[0] as List<dynamic>);
      minLat = bounds['minLat']!;
      maxLat = bounds['maxLat']!;
      minLng = bounds['minLng']!;
      maxLng = bounds['maxLng']!;
    } else if (geometryType == 'MultiPolygon') {
      final List<dynamic> polygons = geometry['coordinates'] as List<dynamic>;
      for (var polygon in polygons) {
        final bounds = _calculateBounds(polygon[0] as List<dynamic>);
        minLat = bounds['minLat']! < minLat ? bounds['minLat']! : minLat;
        maxLat = bounds['maxLat']! > maxLat ? bounds['maxLat']! : maxLat;
        minLng = bounds['minLng']! < minLng ? bounds['minLng']! : minLng;
        maxLng = bounds['maxLng']! > maxLng ? bounds['maxLng']! : maxLng;
      }
    }

    return {
      'minLat': minLat,
      'maxLat': maxLat,
      'minLng': minLng,
      'maxLng': maxLng,
    };
  }

  /// Calculate bounds for a polygon ring
  Map<String, double> _calculateBounds(List<dynamic> ring) {
    double minLat = 90;
    double maxLat = -90;
    double minLng = 180;
    double maxLng = -180;

    for (var point in ring) {
      final List<dynamic> coord = point as List<dynamic>;
      final double lng = coord[0] as double;
      final double lat = coord[1] as double;

      minLat = lat < minLat ? lat : minLat;
      maxLat = lat > maxLat ? lat : maxLat;
      minLng = lng < minLng ? lng : minLng;
      maxLng = lng > maxLng ? lng : maxLng;
    }

    return {
      'minLat': minLat,
      'maxLat': maxLat,
      'minLng': minLng,
      'maxLng': maxLng,
    };
  }
}
