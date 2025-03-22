/// Model representing a country in the app.
class Country {
  /// Unique identifier for the country
  final String id;

  /// The name of the country
  final String name;

  /// The ISO 3166-1 alpha-2 code for the country (e.g., 'US', 'GB')
  final String code;

  /// The continent the country belongs to
  final String continent;

  /// The capital city of the country
  final String capital;

  /// The latitude coordinate of the country's center
  final double latitude;

  /// The longitude coordinate of the country's center
  final double longitude;

  /// A list of neighboring country IDs
  final List<String> neighbors;

  /// The population of the country
  final int population;

  /// The area of the country in square kilometers
  final double area;

  /// The flag emoji for the country
  final String flagEmoji;

  /// Creates a new Country instance.
  const Country({
    required this.id,
    required this.name,
    required this.code,
    required this.continent,
    required this.capital,
    required this.latitude,
    required this.longitude,
    required this.neighbors,
    required this.population,
    required this.area,
    required this.flagEmoji,
  });

  /// Creates a Country from a JSON map.
  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      continent: json['continent'] as String,
      capital: json['capital'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      neighbors: List<String>.from(json['neighbors'] as List),
      population: json['population'] as int,
      area: json['area'] as double,
      flagEmoji: json['flagEmoji'] as String,
    );
  }

  /// Converts the Country to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'continent': continent,
      'capital': capital,
      'latitude': latitude,
      'longitude': longitude,
      'neighbors': neighbors,
      'population': population,
      'area': area,
      'flagEmoji': flagEmoji,
    };
  }

  /// Creates a copy of this Country with the given fields replaced with new values.
  Country copyWith({
    String? id,
    String? name,
    String? code,
    String? continent,
    String? capital,
    double? latitude,
    double? longitude,
    List<String>? neighbors,
    int? population,
    double? area,
    String? flagEmoji,
  }) {
    return Country(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      continent: continent ?? this.continent,
      capital: capital ?? this.capital,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      neighbors: neighbors ?? this.neighbors,
      population: population ?? this.population,
      area: area ?? this.area,
      flagEmoji: flagEmoji ?? this.flagEmoji,
    );
  }

  @override
  String toString() {
    return 'Country(id: $id, name: $name, code: $code)';
  }
}
