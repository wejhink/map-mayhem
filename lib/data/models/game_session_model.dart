/// Represents the result of a single country guess in a game session.
class GuessResult {
  /// The ID of the country that was the target
  final String targetCountryId;

  /// The ID of the country that was guessed (if any)
  final String? guessedCountryId;

  /// Whether the guess was correct
  final bool isCorrect;

  /// The time taken to make the guess in milliseconds
  final int timeTakenMs;

  /// Whether a hint was used for this guess
  final bool hintUsed;

  /// The timestamp when this guess was made
  final DateTime timestamp;

  /// Creates a new GuessResult instance.
  const GuessResult({
    required this.targetCountryId,
    this.guessedCountryId,
    required this.isCorrect,
    required this.timeTakenMs,
    this.hintUsed = false,
    required this.timestamp,
  });

  /// Creates a GuessResult from a JSON map.
  factory GuessResult.fromJson(Map<String, dynamic> json) {
    return GuessResult(
      targetCountryId: json['targetCountryId'] as String,
      guessedCountryId: json['guessedCountryId'] as String?,
      isCorrect: json['isCorrect'] as bool,
      timeTakenMs: json['timeTakenMs'] as int,
      hintUsed: json['hintUsed'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Converts the GuessResult to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'targetCountryId': targetCountryId,
      'guessedCountryId': guessedCountryId,
      'isCorrect': isCorrect,
      'timeTakenMs': timeTakenMs,
      'hintUsed': hintUsed,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'GuessResult(targetCountryId: $targetCountryId, guessedCountryId: $guessedCountryId, isCorrect: $isCorrect)';
  }
}

/// Enum representing the different game modes.
enum GameMode {
  /// Practice mode - learn at your own pace with spaced repetition
  practice,

  /// Challenge mode - test your knowledge against the clock
  challenge,

  /// Custom mode - focus on specific regions or countries
  custom,
}

/// Enum representing the difficulty level of a game session.
enum DifficultyLevel {
  /// Easy difficulty - slower pace, more hints
  easy,

  /// Medium difficulty - balanced learning experience
  medium,

  /// Hard difficulty - faster pace, fewer hints
  hard,
}

/// Model representing a game session.
class GameSession {
  /// Unique identifier for the session
  final String id;

  /// The user ID associated with this session
  final String userId;

  /// The game mode for this session
  final GameMode gameMode;

  /// The difficulty level for this session
  final DifficultyLevel difficultyLevel;

  /// The list of country IDs included in this session
  final List<String> countryIds;

  /// The list of guess results for this session
  final List<GuessResult> guessResults;

  /// The start time of the session
  final DateTime startTime;

  /// The end time of the session (null if not completed)
  final DateTime? endTime;

  /// Whether the session was completed
  final bool isCompleted;

  /// The total score for the session
  final int score;

  /// Creates a new GameSession instance.
  const GameSession({
    required this.id,
    required this.userId,
    required this.gameMode,
    required this.difficultyLevel,
    required this.countryIds,
    required this.guessResults,
    required this.startTime,
    this.endTime,
    this.isCompleted = false,
    this.score = 0,
  });

  /// Creates a GameSession from a JSON map.
  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      id: json['id'] as String,
      userId: json['userId'] as String,
      gameMode: GameMode.values.byName(json['gameMode'] as String),
      difficultyLevel: DifficultyLevel.values.byName(json['difficultyLevel'] as String),
      countryIds: List<String>.from(json['countryIds'] as List),
      guessResults: (json['guessResults'] as List).map((e) => GuessResult.fromJson(e as Map<String, dynamic>)).toList(),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      isCompleted: json['isCompleted'] as bool,
      score: json['score'] as int,
    );
  }

  /// Converts the GameSession to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'gameMode': gameMode.name,
      'difficultyLevel': difficultyLevel.name,
      'countryIds': countryIds,
      'guessResults': guessResults.map((e) => e.toJson()).toList(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'isCompleted': isCompleted,
      'score': score,
    };
  }

  /// Creates a copy of this GameSession with the given fields replaced with new values.
  GameSession copyWith({
    String? id,
    String? userId,
    GameMode? gameMode,
    DifficultyLevel? difficultyLevel,
    List<String>? countryIds,
    List<GuessResult>? guessResults,
    DateTime? startTime,
    DateTime? endTime,
    bool? isCompleted,
    int? score,
  }) {
    return GameSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gameMode: gameMode ?? this.gameMode,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      countryIds: countryIds ?? this.countryIds,
      guessResults: guessResults ?? this.guessResults,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      score: score ?? this.score,
    );
  }

  /// Adds a guess result to the session.
  GameSession addGuessResult(GuessResult result) {
    final newGuessResults = List<GuessResult>.from(guessResults)..add(result);

    // Calculate new score
    int newScore = score;
    if (result.isCorrect) {
      // Base score for correct answer
      int baseScore = 10;

      // Bonus for quick answers (under 10 seconds)
      if (result.timeTakenMs < 10000) {
        baseScore += (10 - (result.timeTakenMs / 1000).floor());
      }

      // Penalty for using hints
      if (result.hintUsed) {
        baseScore = (baseScore * 0.7).floor();
      }

      // Difficulty multiplier
      double multiplier = 1.0;
      switch (difficultyLevel) {
        case DifficultyLevel.easy:
          multiplier = 1.0;
          break;
        case DifficultyLevel.medium:
          multiplier = 1.2;
          break;
        case DifficultyLevel.hard:
          multiplier = 1.5;
          break;
      }

      newScore += (baseScore * multiplier).floor();
    }

    return copyWith(
      guessResults: newGuessResults,
      score: newScore,
    );
  }

  /// Completes the session.
  GameSession complete() {
    return copyWith(
      endTime: DateTime.now(),
      isCompleted: true,
    );
  }

  /// Gets the number of correct guesses in the session.
  int get correctGuessCount {
    return guessResults.where((result) => result.isCorrect).length;
  }

  /// Gets the number of incorrect guesses in the session.
  int get incorrectGuessCount {
    return guessResults.where((result) => !result.isCorrect).length;
  }

  /// Gets the accuracy percentage for the session.
  double get accuracy {
    if (guessResults.isEmpty) return 0.0;
    return (correctGuessCount / guessResults.length) * 100;
  }

  /// Gets the total time spent in the session in milliseconds.
  int get totalTimeMs {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime).inMilliseconds;
  }

  /// Gets the average time per guess in milliseconds.
  int get averageTimePerGuessMs {
    if (guessResults.isEmpty) return 0;
    return guessResults.fold<int>(0, (sum, result) => sum + result.timeTakenMs) ~/ guessResults.length;
  }

  /// Gets the current streak of consecutive correct answers.
  int get currentStreak {
    int streak = 0;
    for (int i = guessResults.length - 1; i >= 0; i--) {
      if (guessResults[i].isCorrect) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Gets the longest streak of consecutive correct answers.
  int get longestStreak {
    int currentStreak = 0;
    int maxStreak = 0;

    for (final result in guessResults) {
      if (result.isCorrect) {
        currentStreak++;
        if (currentStreak > maxStreak) {
          maxStreak = currentStreak;
        }
      } else {
        currentStreak = 0;
      }
    }

    return maxStreak;
  }

  @override
  String toString() {
    return 'GameSession(id: $id, gameMode: ${gameMode.name}, correctGuesses: $correctGuessCount/${guessResults.length})';
  }
}
