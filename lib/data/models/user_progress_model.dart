/// Model representing a user's learning progress for a specific country.
class CountryProgress {
  /// The ID of the country this progress is for
  final String countryId;

  /// The number of times the user has correctly identified this country
  final int correctCount;

  /// The number of times the user has incorrectly identified this country
  final int incorrectCount;

  /// The last time the user was tested on this country
  final DateTime lastTestedDate;

  /// The next scheduled date for testing this country (based on spaced repetition)
  final DateTime nextTestDate;

  /// The current difficulty factor for this country (used in spaced repetition algorithm)
  final double difficultyFactor;

  /// The current interval in days for this country (used in spaced repetition algorithm)
  final int intervalDays;

  /// Creates a new CountryProgress instance.
  const CountryProgress({
    required this.countryId,
    this.correctCount = 0,
    this.incorrectCount = 0,
    required this.lastTestedDate,
    required this.nextTestDate,
    this.difficultyFactor = 2.5,
    this.intervalDays = 1,
  });

  /// Creates a CountryProgress from a JSON map.
  factory CountryProgress.fromJson(Map<String, dynamic> json) {
    return CountryProgress(
      countryId: json['countryId'] as String,
      correctCount: json['correctCount'] as int,
      incorrectCount: json['incorrectCount'] as int,
      lastTestedDate: DateTime.parse(json['lastTestedDate'] as String),
      nextTestDate: DateTime.parse(json['nextTestDate'] as String),
      difficultyFactor: json['difficultyFactor'] as double,
      intervalDays: json['intervalDays'] as int,
    );
  }

  /// Converts the CountryProgress to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'countryId': countryId,
      'correctCount': correctCount,
      'incorrectCount': incorrectCount,
      'lastTestedDate': lastTestedDate.toIso8601String(),
      'nextTestDate': nextTestDate.toIso8601String(),
      'difficultyFactor': difficultyFactor,
      'intervalDays': intervalDays,
    };
  }

  /// Creates a copy of this CountryProgress with the given fields replaced with new values.
  CountryProgress copyWith({
    String? countryId,
    int? correctCount,
    int? incorrectCount,
    DateTime? lastTestedDate,
    DateTime? nextTestDate,
    double? difficultyFactor,
    int? intervalDays,
  }) {
    return CountryProgress(
      countryId: countryId ?? this.countryId,
      correctCount: correctCount ?? this.correctCount,
      incorrectCount: incorrectCount ?? this.incorrectCount,
      lastTestedDate: lastTestedDate ?? this.lastTestedDate,
      nextTestDate: nextTestDate ?? this.nextTestDate,
      difficultyFactor: difficultyFactor ?? this.difficultyFactor,
      intervalDays: intervalDays ?? this.intervalDays,
    );
  }

  /// Updates the progress based on a correct answer.
  CountryProgress updateWithCorrectAnswer() {
    final now = DateTime.now();

    // Calculate new difficulty factor and interval using FSRS algorithm
    // This is a simplified version of the algorithm
    final newDifficultyFactor = difficultyFactor + (0.1 - (5 - 5) * (0.08 + (5 - 5) * 0.02));
    final adjustedDifficultyFactor = newDifficultyFactor < 1.3 ? 1.3 : newDifficultyFactor;
    final newIntervalDays = (intervalDays * adjustedDifficultyFactor).round();

    // Calculate next test date
    final newNextTestDate = now.add(Duration(days: newIntervalDays));

    return copyWith(
      correctCount: correctCount + 1,
      lastTestedDate: now,
      nextTestDate: newNextTestDate,
      difficultyFactor: adjustedDifficultyFactor,
      intervalDays: newIntervalDays,
    );
  }

  /// Updates the progress based on an incorrect answer.
  CountryProgress updateWithIncorrectAnswer() {
    final now = DateTime.now();

    // Reset interval and reduce difficulty factor
    const newIntervalDays = 1;
    final newDifficultyFactor = difficultyFactor * 0.8;
    final adjustedDifficultyFactor = newDifficultyFactor < 1.3 ? 1.3 : newDifficultyFactor;

    // Calculate next test date (test again soon)
    final newNextTestDate = now.add(const Duration(days: 1));

    return copyWith(
      incorrectCount: incorrectCount + 1,
      lastTestedDate: now,
      nextTestDate: newNextTestDate,
      difficultyFactor: adjustedDifficultyFactor,
      intervalDays: newIntervalDays,
    );
  }

  /// Calculates the mastery percentage for this country.
  double get masteryPercentage {
    final totalAttempts = correctCount + incorrectCount;
    if (totalAttempts == 0) return 0.0;
    return (correctCount / totalAttempts) * 100;
  }

  /// Determines if this country is due for review.
  bool isDueForReview() {
    return DateTime.now().isAfter(nextTestDate);
  }

  @override
  String toString() {
    return 'CountryProgress(countryId: $countryId, correctCount: $correctCount, incorrectCount: $incorrectCount)';
  }
}

/// Model representing a user's overall learning progress.
class UserProgress {
  /// The unique identifier for the user
  final String userId;

  /// The map of country progress, keyed by country ID
  final Map<String, CountryProgress> countryProgressMap;

  /// The total number of completed learning sessions
  final int completedSessions;

  /// The total number of correct answers across all countries
  final int totalCorrectAnswers;

  /// The total number of incorrect answers across all countries
  final int totalIncorrectAnswers;

  /// The current streak of consecutive days with learning activity
  final int currentStreak;

  /// The longest streak of consecutive days with learning activity
  final int longestStreak;

  /// The last date the user had learning activity
  final DateTime lastActivityDate;

  /// Creates a new UserProgress instance.
  const UserProgress({
    required this.userId,
    required this.countryProgressMap,
    this.completedSessions = 0,
    this.totalCorrectAnswers = 0,
    this.totalIncorrectAnswers = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.lastActivityDate,
  });

  /// Creates a UserProgress from a JSON map.
  factory UserProgress.fromJson(Map<String, dynamic> json) {
    final countryProgressJson = json['countryProgressMap'] as Map<String, dynamic>;
    final countryProgressMap = countryProgressJson.map(
      (key, value) => MapEntry(
        key,
        CountryProgress.fromJson(value as Map<String, dynamic>),
      ),
    );

    return UserProgress(
      userId: json['userId'] as String,
      countryProgressMap: countryProgressMap,
      completedSessions: json['completedSessions'] as int,
      totalCorrectAnswers: json['totalCorrectAnswers'] as int,
      totalIncorrectAnswers: json['totalIncorrectAnswers'] as int,
      currentStreak: json['currentStreak'] as int,
      longestStreak: json['longestStreak'] as int,
      lastActivityDate: DateTime.parse(json['lastActivityDate'] as String),
    );
  }

  /// Converts the UserProgress to a JSON map.
  Map<String, dynamic> toJson() {
    final countryProgressJson = countryProgressMap.map(
      (key, value) => MapEntry(key, value.toJson()),
    );

    return {
      'userId': userId,
      'countryProgressMap': countryProgressJson,
      'completedSessions': completedSessions,
      'totalCorrectAnswers': totalCorrectAnswers,
      'totalIncorrectAnswers': totalIncorrectAnswers,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActivityDate': lastActivityDate.toIso8601String(),
    };
  }

  /// Creates a copy of this UserProgress with the given fields replaced with new values.
  UserProgress copyWith({
    String? userId,
    Map<String, CountryProgress>? countryProgressMap,
    int? completedSessions,
    int? totalCorrectAnswers,
    int? totalIncorrectAnswers,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
  }) {
    return UserProgress(
      userId: userId ?? this.userId,
      countryProgressMap: countryProgressMap ?? this.countryProgressMap,
      completedSessions: completedSessions ?? this.completedSessions,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      totalIncorrectAnswers: totalIncorrectAnswers ?? this.totalIncorrectAnswers,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
    );
  }

  /// Updates the user progress with a completed session.
  UserProgress updateWithCompletedSession({
    required int correctAnswers,
    required int incorrectAnswers,
  }) {
    final now = DateTime.now();

    // Calculate streak
    final isConsecutiveDay = lastActivityDate.day == now.day - 1 ||
        (lastActivityDate.day == now.day && lastActivityDate.month == now.month && lastActivityDate.year == now.year);

    int newCurrentStreak = currentStreak;
    int newLongestStreak = longestStreak;

    if (isConsecutiveDay) {
      newCurrentStreak += 1;
      if (newCurrentStreak > newLongestStreak) {
        newLongestStreak = newCurrentStreak;
      }
    } else if (lastActivityDate.day != now.day ||
        lastActivityDate.month != now.month ||
        lastActivityDate.year != now.year) {
      // Reset streak if not consecutive and not the same day
      newCurrentStreak = 1;
    }

    return copyWith(
      completedSessions: completedSessions + 1,
      totalCorrectAnswers: totalCorrectAnswers + correctAnswers,
      totalIncorrectAnswers: totalIncorrectAnswers + incorrectAnswers,
      currentStreak: newCurrentStreak,
      longestStreak: newLongestStreak,
      lastActivityDate: now,
    );
  }

  /// Updates the progress for a specific country.
  UserProgress updateCountryProgress(CountryProgress updatedProgress) {
    final newMap = Map<String, CountryProgress>.from(countryProgressMap);
    newMap[updatedProgress.countryId] = updatedProgress;

    return copyWith(
      countryProgressMap: newMap,
      lastActivityDate: DateTime.now(),
    );
  }

  /// Gets a list of countries due for review.
  List<String> getDueCountries() {
    return countryProgressMap.values
        .where((progress) => progress.isDueForReview())
        .map((progress) => progress.countryId)
        .toList();
  }

  /// Calculates the overall accuracy percentage.
  double get overallAccuracy {
    final totalAttempts = totalCorrectAnswers + totalIncorrectAnswers;
    if (totalAttempts == 0) return 0.0;
    return (totalCorrectAnswers / totalAttempts) * 100;
  }

  /// Gets the number of countries with at least one correct answer.
  int get countriesLearned {
    return countryProgressMap.values.where((progress) => progress.correctCount > 0).length;
  }

  @override
  String toString() {
    return 'UserProgress(userId: $userId, countriesLearned: $countriesLearned, completedSessions: $completedSessions)';
  }
}
