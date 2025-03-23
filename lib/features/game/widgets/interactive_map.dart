import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_mayhem/core/services/geojson_service.dart';
import 'package:map_mayhem/core/services/map_service.dart';
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

  /// Whether to show the correct country with a circle
  final bool showCorrectCountry;

  /// Whether to show the incorrect selection with a circle
  final bool showIncorrectSelection;

  /// Creates an interactive map widget.
  const InteractiveMap({
    super.key,
    required this.geoJsonService,
    this.onCountryTap,
    this.highlightedCountryId,
    this.targetCountryId,
    this.showCorrectCountry = false,
    this.showIncorrectSelection = false,
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
        initialCenter: _center,
        initialZoom: _zoom,
        maxZoom: 10,
        minZoom: 1,
        onTap: _handleMapTap,
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.all,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://klokantech.github.io/naturalearthtiles/tiles/natural_earth_2_shaded_relief.raster/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.jhink.map_mayhem',
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
        if (id == widget.targetCountryId) {
          // Correct selection
          fillColor = AppColors.success.withAlpha(128);
          borderColor = AppColors.success;
          borderStrokeWidth = 3.0;
        } else {
          // Incorrect selection
          fillColor = AppColors.accent.withAlpha(128);
          borderColor = AppColors.accent;
          borderStrokeWidth = 3.0;
        }
      } else if (id == widget.targetCountryId && widget.showCorrectCountry) {
        // Target country (show when an incorrect selection is made)
        fillColor = AppColors.success.withAlpha(128);
        borderColor = AppColors.success;
        borderStrokeWidth = 4.0;
      } else {
        // Regular country
        fillColor = Colors.grey.withAlpha(51);
        borderColor = Colors.grey.withAlpha(128);
        borderStrokeWidth = 1.0;
      }

      // Extract points for all polygons in this country
      final List<List<LatLng>> countryPolygons = _extractPointsFromCountry(country);

      // Create a Flutter Polygon for each polygon in the country
      for (final points in countryPolygons) {
        if (points.isNotEmpty) {
          // Determine if we should show the label for this country
          final bool showLabel =
              id == widget.targetCountryId && (widget.showCorrectCountry || id == widget.highlightedCountryId);

          polygons.add(
            Polygon(
              points: points,
              color: fillColor,
              borderColor: borderColor,
              borderStrokeWidth: borderStrokeWidth,
              // Add label only for the target country when it's selected or revealed
              label: showLabel ? country.name : null,
              labelStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
                backgroundColor: Colors.white70,
              ),
              labelPlacement: PolygonLabelPlacement.centroid,
            ),
          );
        }
      }
    }

    return polygons;
  }

  /// Extract points from a country's geometry
  /// Returns a list of polygon point lists, since a country can have multiple polygons
  List<List<LatLng>> _extractPointsFromCountry(GeoJsonCountry country) {
    final List<List<LatLng>> polygons = [];
    final Map<String, dynamic> geometry = country.geometry;
    final String geometryType = geometry['type'] as String;

    if (geometryType == 'Polygon') {
      final List<dynamic> coordinates = geometry['coordinates'] as List<dynamic>;
      // Use the first ring (outer ring) of the polygon
      final List<dynamic> ring = coordinates[0] as List<dynamic>;

      final List<LatLng> points = [];
      for (var point in ring) {
        final List<dynamic> coord = point as List<dynamic>;
        final double lng = coord[0] as double;
        final double lat = coord[1] as double;
        points.add(LatLng(lat, lng));
      }

      if (points.isNotEmpty) {
        polygons.add(points);
      }
    } else if (geometryType == 'MultiPolygon') {
      final List<dynamic> multiPolygon = geometry['coordinates'] as List<dynamic>;

      // Process all polygons in the MultiPolygon
      for (var polygon in multiPolygon) {
        // Use the first ring (outer ring) of each polygon
        final List<dynamic> ring = polygon[0] as List<dynamic>;

        final List<LatLng> points = [];
        for (var point in ring) {
          final List<dynamic> coord = point as List<dynamic>;
          final double lng = coord[0] as double;
          final double lat = coord[1] as double;
          points.add(LatLng(lat, lng));
        }

        if (points.isNotEmpty) {
          polygons.add(points);
        }
      }
    }

    return polygons;
  }
}
