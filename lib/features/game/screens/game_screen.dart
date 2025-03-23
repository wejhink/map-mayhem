import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:map_mayhem/core/services/geojson_service.dart';
import 'package:map_mayhem/core/services/map_service.dart';
import 'package:map_mayhem/data/models/country_model.dart';
import 'package:map_mayhem/features/game/widgets/interactive_map.dart';
import 'package:map_mayhem/presentation/themes/app_colors.dart';
import 'package:map_mayhem/presentation/themes/app_text_styles.dart';

/// The main game screen where users interact with the map.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Services
  late MapService _mapService;
  late GeoJsonService _geoJsonService;

  // Game state
  late Country _currentCountry;
  String? _selectedCountryId;
  bool _isCorrectAnswer = false;

  // Game stats
  int _score = 0;
  int _streak = 0;
  int _remaining = 10;

  // List of countries for the current game session
  List<Country> _gameCountries = [];

  @override
  void initState() {
    super.initState();

    // Get services from provider
    _mapService = Provider.of<MapService>(context, listen: false);
    _geoJsonService = Provider.of<GeoJsonService>(context, listen: false);

    _initializeGame();
  }

  Future<void> _initializeGame() async {
    // Get random countries for the game
    _gameCountries = _mapService.getRandomCountries(count: 10);

    // Set the first country as the current target
    if (_gameCountries.isNotEmpty) {
      setState(() {
        _currentCountry = _gameCountries.first;
        _remaining = _gameCountries.length;
      });
    } else {
      // Fallback if no countries are loaded
      _currentCountry = Country(
        id: 'FRA',
        name: 'France',
        code: 'FR',
        continent: 'Europe',
        capital: 'Paris',
        latitude: 46.2276,
        longitude: 2.2137,
        neighbors: ['ESP', 'DEU', 'ITA', 'CHE', 'BEL', 'LUX'],
        population: 67000000,
        area: 551695,
        flagEmoji: '🇫🇷',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Mode'),
        actions: [
          // Help button
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              _showHelpDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Game stats bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Score
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Score',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '$_score',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.primaryLight
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
                // Streak
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Streak',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '$_streak',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            Theme.of(context).brightness == Brightness.dark ? AppColors.accentLight : AppColors.accent,
                      ),
                    ),
                  ],
                ),
                // Remaining
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Remaining',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '$_remaining',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Current country prompt
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Find this country:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentCountry.name,
                  style: Theme.of(context).brightness == Brightness.dark
                      ? AppTextStyles.countryNameDark
                      : AppTextStyles.countryName,
                ),
              ],
            ),
          ),

          // Interactive Map
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2C2C2C) : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[400]!,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: InteractiveMap(
                  geoJsonService: _geoJsonService,
                  onCountryTap: _handleCountryTap,
                  highlightedCountryId: _selectedCountryId,
                  targetCountryId: _isCorrectAnswer ? _currentCountry.id : null,
                ),
              ),
            ),
          ),

          // Bottom controls
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Skip button
                OutlinedButton.icon(
                  onPressed: () {
                    _showSkipDialog();
                  },
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Skip'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),

                // Hint button
                ElevatedButton.icon(
                  onPressed: () {
                    _showHint();
                  },
                  icon: const Icon(Icons.lightbulb_outline),
                  label: const Text('Hint'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Handle country tap on the map
  void _handleCountryTap(String countryId) {
    setState(() {
      _selectedCountryId = countryId;

      // Check if the selected country is the target country
      if (countryId == _currentCountry.id) {
        _isCorrectAnswer = true;
        _showCorrectAnswer();
      } else {
        _showIncorrectAnswer();
      }
    });
  }

  // Show help dialog
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Play'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. A country name will be displayed at the top'),
            const SizedBox(height: 8),
            Text('2. Find and tap on that country on the map'),
            const SizedBox(height: 8),
            Text('3. Correct answers earn points and increase your streak'),
            const SizedBox(height: 8),
            Text('4. Use hints if you need help finding a country'),
            const SizedBox(height: 8),
            Text('5. The app uses spaced repetition to help you learn efficiently'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  // Show skip dialog
  void _showSkipDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip this country?'),
        content: const Text('You won\'t lose points, but your streak will reset.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _moveToNextCountry(skipPenalty: true);
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  // Show hint
  void _showHint() {
    final hints = _mapService.getCountryHint(_currentCountry.id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hint for ${_currentCountry.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location: ${hints['continent'] ?? 'Unknown'}'),
            const SizedBox(height: 8),
            Text('Capital: ${hints['capital'] ?? 'Unknown'}'),
            const SizedBox(height: 8),
            Text('Neighbors: ${hints['neighbors'] ?? 'None'}'),
            if (hints['flag'] != null) ...[
              const SizedBox(height: 8),
              Text('Flag: ${hints['flag']}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Thanks'),
          ),
        ],
      ),
    );
  }

  // Move to the next country in the game
  void _moveToNextCountry({bool skipPenalty = false}) {
    // Remove the current country from the list
    _gameCountries.removeWhere((country) => country.id == _currentCountry.id);

    setState(() {
      if (skipPenalty) {
        _streak = 0;
      }

      _remaining = _gameCountries.length;
      _selectedCountryId = null;
      _isCorrectAnswer = false;

      if (_gameCountries.isNotEmpty) {
        // Set the next country as the current target
        _currentCountry = _gameCountries.first;
      } else {
        // Game over - in a real app, we would show a game over screen
        // For now, just restart with new countries
        _initializeGame();
      }
    });
  }

  // Show correct answer feedback
  void _showCorrectAnswer() {
    setState(() {
      _score += 10;
      _streak++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Correct! Well done!'),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        onVisible: () {
          // Wait for the snackbar to be visible before moving to the next country
          Future.delayed(const Duration(seconds: 2), () {
            _moveToNextCountry();
          });
        },
      ),
    );
  }

  // Show incorrect answer feedback
  void _showIncorrectAnswer() {
    setState(() {
      _streak = 0;
      _isCorrectAnswer = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.cancel, color: Colors.white),
            SizedBox(width: 8),
            Text('Incorrect. Try again!'),
          ],
        ),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
