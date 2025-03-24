import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

/// Service responsible for managing all audio in the application.
/// Handles platform-specific audio behavior, particularly for web platforms
/// where autoplay restrictions apply.
class AudioService {
  // Audio players
  late AudioPlayer _musicPlayer;
  late AudioPlayer _sfxPlayer;

  // Web-specific flags
  bool _isUserInteractionRequired = false;
  bool _hasUserInteracted = false;

  // Audio files
  static const String _buttonSound = 'assets/music/button.mp3';
  static const String _correctSound = 'assets/music/correct.mp3';
  static const String _incorrectSound = 'assets/music/incorrect.mp3';
  static const String _hintSound = 'assets/music/hint.mp3';
  static const String _nextLevelSound = 'assets/music/next_level.mp3';
  static const String _nextStepSound = 'assets/music/next.mp3';
  static const String _strikeSound = 'assets/music/strike.mp3';
  static const String _gamePlayMusic = 'assets/music/game_play_0_clarity.mp3';
  static const String _menuMusic = 'assets/music/menu_music.mp3';

  // Settings
  bool _isMusicEnabled = true;
  bool _isSfxEnabled = true;
  double _musicVolume = 0.5;
  double _sfxVolume = 0.7;

  // Getters for settings
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSfxEnabled => _isSfxEnabled;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  /// Initialize the audio service
  Future<void> init() async {
    try {
      _musicPlayer = AudioPlayer();
      _sfxPlayer = AudioPlayer();

      // Set initial volumes
      await _musicPlayer.setVolume(_musicVolume);
      await _sfxPlayer.setVolume(_sfxVolume);

      // Check if we're on web platform
      if (kIsWeb) {
        _isUserInteractionRequired = true;
        _hasUserInteracted = false;
        debugPrint('Web platform detected. Audio will require user interaction first.');
      } else {
        _hasUserInteracted = true; // Non-web platforms don't have this restriction
      }

      debugPrint('AudioService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing AudioService: $e');
    }
  }

  /// Mark that user has interacted with the app
  /// This is needed for web platforms due to autoplay restrictions
  void userHasInteracted() {
    _hasUserInteracted = true;
    debugPrint('User interaction registered. Audio can now play.');
  }

  /// Check if audio can be played (for web platforms)
  bool get canPlayAudio => !_isUserInteractionRequired || _hasUserInteracted;

  /// Dispose audio players
  Future<void> dispose() async {
    await _musicPlayer.dispose();
    await _sfxPlayer.dispose();
  }

  /// Play a sound effect
  Future<void> playSfx(String assetPath) async {
    if (!_isSfxEnabled) return;

    // Skip if on web and user hasn't interacted yet
    if (!canPlayAudio) {
      debugPrint('Skipping sound effect: User interaction required first');
      return;
    }

    try {
      await _sfxPlayer.setAsset(assetPath);
      await _sfxPlayer.play();
    } catch (e) {
      debugPrint('Error playing sound effect: $e');
    }
  }

  /// Play button click sound
  Future<void> playButtonSound() async {
    await playSfx(_buttonSound);
  }

  /// Play correct answer sound
  Future<void> playCorrectSound() async {
    await playSfx(_correctSound);
  }

  /// Play incorrect answer sound
  Future<void> playIncorrectSound() async {
    await playSfx(_incorrectSound);
  }

  /// Play hint sound
  Future<void> playHintSound() async {
    await playSfx(_hintSound);
  }

  /// Play next level sound
  Future<void> playNextLevelSound() async {
    await playSfx(_nextLevelSound);
  }

  /// Play next step sound
  Future<void> playNextStepSound() async {
    await playSfx(_nextStepSound);
  }

  /// Play streak sound
  Future<void> playStreakSound() async {
    await playSfx(_strikeSound);
  }

  /// Play background music
  Future<void> playBackgroundMusic(String assetPath, {bool loop = true}) async {
    if (!_isMusicEnabled) return;

    // Skip if on web and user hasn't interacted yet
    if (!canPlayAudio) {
      debugPrint('Skipping background music: User interaction required first');
      return;
    }

    try {
      await _musicPlayer.setAsset(assetPath);
      await _musicPlayer.setLoopMode(loop ? LoopMode.one : LoopMode.off);
      await _musicPlayer.play();
    } catch (e) {
      debugPrint('Error playing background music: $e');
    }
  }

  /// Try to play background music again (useful after user interaction)
  Future<void> retryPlayBackgroundMusic(String assetPath, {bool loop = true}) async {
    if (canPlayAudio) {
      await playBackgroundMusic(assetPath, loop: loop);
    }
  }

  /// Play game music
  Future<void> playGameMusic() async {
    await playBackgroundMusic(_gamePlayMusic);
  }

  /// Play menu music
  Future<void> playMenuMusic() async {
    await playBackgroundMusic(_menuMusic);
  }

  /// Stop background music
  Future<void> stopBackgroundMusic() async {
    await _musicPlayer.stop();
  }

  /// Pause background music
  Future<void> pauseBackgroundMusic() async {
    await _musicPlayer.pause();
  }

  /// Resume background music
  Future<void> resumeBackgroundMusic() async {
    if (_isMusicEnabled) {
      await _musicPlayer.play();
    }
  }

  /// Set music enabled/disabled
  Future<void> setMusicEnabled(bool enabled) async {
    _isMusicEnabled = enabled;
    if (enabled && canPlayAudio) {
      await resumeBackgroundMusic();
    } else {
      await pauseBackgroundMusic();
    }
  }

  /// Set sound effects enabled/disabled
  void setSfxEnabled(bool enabled) {
    _isSfxEnabled = enabled;
  }

  /// Set music volume
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume;
    await _musicPlayer.setVolume(volume);
  }

  /// Set sound effects volume
  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume;
    await _sfxPlayer.setVolume(volume);
  }

  /// Show a dialog to enable audio (for web platforms)
  /// This helps satisfy browser autoplay policies by requiring user interaction
  static Future<void> showEnableAudioDialog(BuildContext context) async {
    if (!kIsWeb) return; // Only needed for web

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Audio'),
        content: const Text(
          'Browser security requires user interaction before playing audio.\n\n'
          'Click the button below to enable sounds and music in the app.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              final audioService = Provider.of<AudioService>(context, listen: false);
              audioService.userHasInteracted();
              Navigator.of(context).pop();
            },
            child: const Text('Enable Audio'),
          ),
        ],
      ),
    );
  }
}
