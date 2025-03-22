import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_mayhem/core/services/geojson_service.dart';
import 'package:map_mayhem/data/models/country_model.dart';
import 'package:map_mayhem/presentation/themes/app_colors.dart';

/// A widget that displays an interactive map with country boundaries.
class InteractiveMap extends StatefulWidget {
  /// The GeoJSON service to use for map data.
  final GeoJsonService geoJsonService;

  /// Callback when a country is tapped.
  final Function(String countryId)? onCountryTap;

  /// The currently highlighted country ID, if any.
  final String? highlightedCountryId;

  /// The currently targeted country ID for the game.
  final String? targetCountryId;

  /// Creates an interactive map widget.
  const InteractiveMap({
    super.key,
    required this.geoJsonService,
    this.onCountryTap,
    this.highlightedCountryId,
    this.targetCountryId,
  });

  @override
  State<InteractiveMap> createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<InteractiveMap> {
  final MapController _mapController = MapController();
  List<GeoJsonCountry> _countryFeatures = [];

  // Default map center and zoom
  LatLng _center = LatLng(0, 0);
  double _zoom = 2.0;

  @override
  void initState() {
    super.initState();
    _loadCountryFeatures();
  }

  @override
  void didUpdateWidget(InteractiveMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the target country changed, zoom to it
    if (widget.targetCountryId != null && widget.targetCountryId != oldWidget.targetCountryId) {
      _zoomToCountry(widget.targetCountryId!);
    }
  }

  void _loadCountryFeatures() {
    _countryFeatures = widget.geoJsonService.getAllCountryFeatures();
  }

  void _zoomToCountry(String countryId) {
    final bounds = widget.geoJsonService.getCountryBounds(countryId);

    if (bounds['minLat'] == 0 && bounds['maxLat'] == 0) {
      return; // Invalid bounds
    }

    // Calculate center
    final centerLat = (bounds['minLat']! + bounds['maxLat']!) / 2;
    final centerLng = (bounds['minLng']! + bounds['maxLng']!) / 2;

    // Calculate appropriate zoom level
    final latDiff = (bounds['maxLat']! - bounds['minLat']!).abs();
    final lngDiff = (bounds['maxLng']! - bounds['minLng']!).abs();

    // Adjust zoom based on country size
    double zoom = 5.0;
    if (latDiff > 20 || lngDiff > 20) {
      zoom = 3.0;
    } else if (latDiff > 10 || lngDiff > 10) {
      zoom = 4.0;
    } else if (latDiff < 2 || lngDiff < 2) {
      zoom = 7.0;
    }

    setState(() {
      _center = LatLng(centerLat, centerLng);
      _zoom = zoom;
    });

    _mapController.move(_center, _zoom);
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: _center,
        zoom: _zoom,
        maxZoom: 10,
        minZoom: 1,
        interactiveFlags: InteractiveFlag.all,
        onTap: _handleMapTap,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.map_mayhem',
        ),
        PolygonLayer(
          polygons: _buildCountryPolygons(),
        ),
      ],
    );
  }

  void _handleMapTap(TapPosition tapPosition, LatLng point) {
    final countryId = widget.geoJsonService.getCountryIdAtPoint(
      point.latitude,
      point.longitude,
    );

    if (countryId != null && widget.onCountryTap != null) {
      widget.onCountryTap!(countryId);
    }
  }

  List<Polygon> _buildCountryPolygons() {
    final List<Polygon> polygons = [];

    for (final country in _countryFeatures) {
      final String? id = country.id;

      if (id == null) continue;

      // Determine the color based on whether this country is highlighted or targeted
      Color fillColor;
      Color borderColor;
      double borderStrokeWidth;

      if (id == widget.highlightedCountryId) {
        // Highlighted country (user's selection)
        fillColor = AppColors.accent.withOpacity(0.5);
        borderColor = AppColors.accent;
        borderStrokeWidth = 2.0;
      } else if (id == widget.targetCountryId) {
        // Target country (only show if it's been correctly identified)
        fillColor = AppColors.success.withOpacity(0.5);
        borderColor = AppColors.success;
        borderStrokeWidth = 2.0;
      } else {
        // Regular country
        fillColor = Colors.grey.withOpacity(0.2);
        borderColor = Colors.grey.withOpacity(0.5);
        borderStrokeWidth = 1.0;
      }

      // Extract points for the polygon
      final List<LatLng> points = _extractPointsFromCountry(country);

      if (points.isNotEmpty) {
        polygons.add(
          Polygon(
            points: points,
            color: fillColor,
            borderColor: borderColor,
            borderStrokeWidth: borderStrokeWidth,
          ),
        );
      }
    }

    return polygons;
  }

  List<LatLng> _extractPointsFromCountry(GeoJsonCountry country) {
    final List<LatLng> points = [];
    final Map<String, dynamic> geometry = country.geometry;
    final String geometryType = geometry['type'] as String;

    if (geometryType == 'Polygon') {
      final List<dynamic> coordinates = geometry['coordinates'] as List<dynamic>;
      // Use the first ring (outer ring) of the polygon
      final List<dynamic> ring = coordinates[0] as List<dynamic>;

      for (var point in ring) {
        final List<dynamic> coord = point as List<dynamic>;
        final double lng = coord[0] as double;
        final double lat = coord[1] as double;
        points.add(LatLng(lat, lng));
      }
    } else if (geometryType == 'MultiPolygon') {
      final List<dynamic> polygons = geometry['coordinates'] as List<dynamic>;
      if (polygons.isNotEmpty) {
        // For simplicity, just use the first polygon in the multipolygon
        final List<dynamic> ring = polygons[0][0] as List<dynamic>;

        for (var point in ring) {
          final List<dynamic> coord = point as List<dynamic>;
          final double lng = coord[0] as double;
          final double lat = coord[1] as double;
          points.add(LatLng(lat, lng));
        }
      }
    }

    return points;
  }
}
