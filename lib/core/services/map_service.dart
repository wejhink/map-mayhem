import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:map_mayhem/data/models/country_model.dart';

/// Service for handling map-related functionality.
class MapService {
  /// List of all countries
  List<Country> _countries = [];

  /// Map of countries by ID for quick lookup
  Map<String, Country> _countriesById = {};

  /// Map of countries by continent for filtering
  Map<String, List<Country>> _countriesByContinent = {};

  /// Initialize the map service.
  Future<void> init() async {
    await _loadCountries();
  }

  /// Load countries from the assets.
  Future<void> _loadCountries() async {
    try {
      // Load the countries JSON file from assets
      final String jsonString = await rootBundle.loadString('assets/maps/countries.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

      // Parse the JSON into Country objects
      _countries = jsonList.map((json) => Country.fromJson(json as Map<String, dynamic>)).toList();

      // Create lookup maps
      _countriesById = {for (var country in _countries) country.id: country};

      // Group countries by continent
      _countriesByContinent = {};
      for (var country in _countries) {
        if (!_countriesByContinent.containsKey(country.continent)) {
          _countriesByContinent[country.continent] = [];
        }
        _countriesByContinent[country.continent]!.add(country);
      }
    } catch (e) {
      // In a real app, we would handle this error more gracefully
      print('Error loading countries: $e');

      // For MVP, initialize with empty lists
      _countries = [];
      _countriesById = {};
      _countriesByContinent = {};
    }
  }

  /// Get all countries.
  List<Country> getAllCountries() {
    return List.unmodifiable(_countries);
  }

  /// Get a country by ID.
  Country? getCountryById(String id) {
    return _countriesById[id];
  }

  /// Get countries by continent.
  List<Country> getCountriesByContinent(String continent) {
    return List.unmodifiable(_countriesByContinent[continent] ?? []);
  }

  /// Get all continents.
  List<String> getAllContinents() {
    return List.unmodifiable(_countriesByContinent.keys.toList());
  }

  /// Get neighboring countries for a given country.
  List<Country> getNeighboringCountries(String countryId) {
    final country = _countriesById[countryId];
    if (country == null) return [];

    return country.neighbors.map((id) => _countriesById[id]).where((c) => c != null).cast<Country>().toList();
  }

  /// Search for countries by name.
  List<Country> searchCountriesByName(String query) {
    if (query.isEmpty) return [];

    final lowercaseQuery = query.toLowerCase();
    return _countries.where((country) => country.name.toLowerCase().contains(lowercaseQuery)).toList();
  }

  /// Get a random selection of countries.
  List<Country> getRandomCountries({int count = 10, String? continent}) {
    final List<Country> sourceList = continent != null ? _countriesByContinent[continent] ?? [] : _countries;

    if (sourceList.isEmpty) return [];
    if (sourceList.length <= count) return List.from(sourceList);

    // Create a copy of the list to shuffle
    final List<Country> shuffled = List.from(sourceList);
    shuffled.shuffle();

    return shuffled.take(count).toList();
  }

  /// Get countries for a practice session based on user progress.
  List<Country> getCountriesForPractice(List<String> dueCountryIds, {int count = 10}) {
    // First, include all due countries
    final List<Country> practiceList =
        dueCountryIds.map((id) => _countriesById[id]).where((country) => country != null).cast<Country>().toList();

    // If we need more countries, add random ones
    if (practiceList.length < count) {
      final neededCount = count - practiceList.length;

      // Get IDs of countries already in the practice list
      final Set<String> existingIds = practiceList.map((c) => c.id).toSet();

      // Create a list of countries not already in the practice list
      final List<Country> remainingCountries =
          _countries.where((country) => !existingIds.contains(country.id)).toList();

      // Shuffle and take the needed number of countries
      remainingCountries.shuffle();
      practiceList.addAll(remainingCountries.take(neededCount));
    }

    return practiceList;
  }

  /// Get a hint for a country.
  Map<String, String> getCountryHint(String countryId) {
    final country = _countriesById[countryId];
    if (country == null) {
      return {
        'error': 'Country not found',
      };
    }

    final neighbors = getNeighboringCountries(countryId);
    final neighborNames = neighbors.map((c) => c.name).join(', ');

    return {
      'name': country.name,
      'continent': country.continent,
      'capital': country.capital,
      'neighbors': neighborNames.isNotEmpty ? neighborNames : 'None (island nation)',
      'flag': country.flagEmoji,
    };
  }

  /// Calculate the distance between two countries in kilometers.
  double calculateDistance(String countryId1, String countryId2) {
    final country1 = _countriesById[countryId1];
    final country2 = _countriesById[countryId2];

    if (country1 == null || country2 == null) {
      return -1; // Error case
    }

    // Calculate distance using the Haversine formula
    const double earthRadius = 6371; // in kilometers

    final lat1 = _degreesToRadians(country1.latitude);
    final lon1 = _degreesToRadians(country1.longitude);
    final lat2 = _degreesToRadians(country2.latitude);
    final lon2 = _degreesToRadians(country2.longitude);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a = _haversine(dLat) + _haversine(dLon) * _cosine(lat1) * _cosine(lat2);

    final c = 2 * _arctangent2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  // Helper methods for distance calculation
  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  double _haversine(double angle) {
    return (1 - _cosine(angle)) / 2;
  }

  double _cosine(double angle) {
    return math.cos(angle);
  }

  double _arctangent2(double y, double x) {
    return math.atan2(y, x);
  }
}
