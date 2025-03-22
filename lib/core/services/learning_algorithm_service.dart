import 'package:map_mayhem/data/models/user_progress_model.dart';

/// Service for handling the spaced repetition learning algorithm.
class LearningAlgorithmService {
  /// Default difficulty factor for new items
  static const double defaultDifficultyFactor = 2.5;

  /// Minimum difficulty factor
  static const double minDifficultyFactor = 1.3;

  /// Default interval in days for new items
  static const int defaultIntervalDays = 1;

  /// Maximum interval in days
  static const int maxIntervalDays = 365;

  /// Calculate the next review date and updated difficulty factor based on the user's response.
  ///
  /// [progress] is the current progress for the country.
  /// [responseQuality] is the quality of the user's response, from 0 (worst) to 5 (best).
  ///
  /// Returns a new CountryProgress with updated values.
  CountryProgress calculateNextReview(CountryProgress progress, int responseQuality) {
    // Validate response quality
    final quality = _clamp(responseQuality, 0, 5);

    // Get current values
    final double currentDifficultyFactor = progress.difficultyFactor;
    final int currentIntervalDays = progress.intervalDays;

    // Calculate new difficulty factor using the SuperMemo-2 algorithm
    final double newDifficultyFactor = _calculateNewDifficultyFactor(
      currentDifficultyFactor,
      quality,
    );

    // Calculate new interval
    final int newIntervalDays = _calculateNewInterval(
      currentIntervalDays,
      newDifficultyFactor,
      quality,
    );

    // Calculate next test date
    final DateTime now = DateTime.now();
    final DateTime nextTestDate = now.add(Duration(days: newIntervalDays));

    // Update correct/incorrect counts
    final int newCorrectCount = quality >= 3 ? progress.correctCount + 1 : progress.correctCount;

    final int newIncorrectCount = quality < 3 ? progress.incorrectCount + 1 : progress.incorrectCount;

    // Return updated progress
    return progress.copyWith(
      correctCount: newCorrectCount,
      incorrectCount: newIncorrectCount,
      lastTestedDate: now,
      nextTestDate: nextTestDate,
      difficultyFactor: newDifficultyFactor,
      intervalDays: newIntervalDays,
    );
  }

  /// Calculate the new difficulty factor based on the current factor and response quality.
  double _calculateNewDifficultyFactor(double currentFactor, int quality) {
    // SuperMemo-2 algorithm for calculating difficulty factor
    final double newFactor = currentFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));

    // Ensure the factor doesn't go below the minimum
    return _clamp(newFactor, minDifficultyFactor, double.infinity);
  }

  /// Calculate the new interval based on the current interval, difficulty factor, and response quality.
  int _calculateNewInterval(int currentInterval, double difficultyFactor, int quality) {
    if (quality < 3) {
      // If the response was poor, reset the interval to 1 day
      return 1;
    } else if (currentInterval == 1) {
      // First successful review
      return 6;
    } else if (currentInterval == 6) {
      // Second successful review
      return 25;
    } else {
      // Subsequent successful reviews
      final int newInterval = (currentInterval * difficultyFactor).round();
      return _clamp(newInterval, 1, maxIntervalDays);
    }
  }

  /// Create a new CountryProgress for a country that hasn't been studied yet.
  CountryProgress createNewCountryProgress(String countryId) {
    final DateTime now = DateTime.now();
    final DateTime tomorrow = now.add(const Duration(days: 1));

    return CountryProgress(
      countryId: countryId,
      correctCount: 0,
      incorrectCount: 0,
      lastTestedDate: now,
      nextTestDate: tomorrow,
      difficultyFactor: defaultDifficultyFactor,
      intervalDays: defaultIntervalDays,
    );
  }

  /// Get a list of country IDs that are due for review.
  List<String> getDueCountries(UserProgress userProgress) {
    return userProgress.getDueCountries();
  }

  /// Calculate the mastery level for a country based on its progress.
  /// Returns a value between 0 (not mastered) and 1 (fully mastered).
  double calculateMasteryLevel(CountryProgress progress) {
    // Calculate mastery based on correct answers and interval
    final int totalAttempts = progress.correctCount + progress.incorrectCount;

    if (totalAttempts == 0) {
      return 0.0;
    }

    // Weight factors
    const double correctRatioWeight = 0.6;
    const double intervalWeight = 0.4;

    // Calculate correct ratio component (0-1)
    final double correctRatio = progress.correctCount / totalAttempts;

    // Calculate interval component (0-1)
    final double intervalRatio = _clamp(
      progress.intervalDays / 100.0, // Normalize to 0-1 range (assuming 100+ days is mastery)
      0.0,
      1.0,
    );

    // Combine the components
    return (correctRatio * correctRatioWeight) + (intervalRatio * intervalWeight);
  }

  /// Helper method to clamp a value between a minimum and maximum.
  T _clamp<T extends num>(T value, T min, T max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
}
