import 'package:flutter/material.dart';
import 'package:map_mayhem/core/services/audio_service.dart';
import 'package:map_mayhem/presentation/themes/app_colors.dart';
import 'package:provider/provider.dart';

/// The settings screen for the app.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Services
  late AudioService _audioService;

  // Settings
  bool _darkMode = false;
  bool _soundEffects = true;
  bool _backgroundMusic = true;
  bool _notifications = true;
  String _difficultyLevel = 'Medium';
  double _musicVolume = 0.5;
  double _sfxVolume = 0.7;

  @override
  void initState() {
    super.initState();

    // Get audio service
    _audioService = Provider.of<AudioService>(context, listen: false);

    // Initialize audio settings from service
    _soundEffects = _audioService.isSfxEnabled;
    _backgroundMusic = _audioService.isMusicEnabled;
    _musicVolume = _audioService.musicVolume;
    _sfxVolume = _audioService.sfxVolume;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // App preferences section
          _buildSectionHeader('App Preferences'),

          // Dark mode toggle
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Enable dark theme'),
            value: _darkMode,
            onChanged: (value) {
              setState(() {
                _darkMode = value;
              });
            },
            secondary: const Icon(Icons.dark_mode),
          ),

          const Divider(),

          // Sound effects toggle
          SwitchListTile(
            title: const Text('Sound Effects'),
            subtitle: const Text('Play sounds during gameplay'),
            value: _soundEffects,
            onChanged: (value) {
              _audioService.playButtonSound();
              setState(() {
                _soundEffects = value;
                _audioService.setSfxEnabled(value);
              });
            },
            secondary: const Icon(Icons.volume_up),
          ),

          // Sound effects volume slider
          if (_soundEffects)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  const Icon(Icons.volume_down, size: 20, color: Colors.grey),
                  Expanded(
                    child: Slider(
                      value: _sfxVolume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      onChanged: (value) {
                        setState(() {
                          _sfxVolume = value;
                          _audioService.setSfxVolume(value);
                        });
                      },
                      onChangeEnd: (value) {
                        _audioService.playButtonSound();
                      },
                    ),
                  ),
                  const Icon(Icons.volume_up, size: 20, color: Colors.grey),
                ],
              ),
            ),

          const Divider(),

          // Background music toggle
          SwitchListTile(
            title: const Text('Background Music'),
            subtitle: const Text('Play music in menus and during gameplay'),
            value: _backgroundMusic,
            onChanged: (value) {
              _audioService.playButtonSound();
              setState(() {
                _backgroundMusic = value;
                _audioService.setMusicEnabled(value);
              });
            },
            secondary: const Icon(Icons.music_note),
          ),

          // Music volume slider
          if (_backgroundMusic)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  const Icon(Icons.volume_down, size: 20, color: Colors.grey),
                  Expanded(
                    child: Slider(
                      value: _musicVolume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      onChanged: (value) {
                        setState(() {
                          _musicVolume = value;
                          _audioService.setMusicVolume(value);
                        });
                      },
                    ),
                  ),
                  const Icon(Icons.volume_up, size: 20, color: Colors.grey),
                ],
              ),
            ),

          const Divider(),

          // Notifications toggle
          SwitchListTile(
            title: const Text('Notifications'),
            subtitle: const Text('Receive learning reminders'),
            value: _notifications,
            onChanged: (value) {
              setState(() {
                _notifications = value;
              });
            },
            secondary: const Icon(Icons.notifications),
          ),

          // Game settings section
          _buildSectionHeader('Game Settings'),

          // Difficulty level
          ListTile(
            title: const Text('Difficulty Level'),
            subtitle: Text(_difficultyLevel),
            leading: const Icon(Icons.tune),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _audioService.playButtonSound();
              _showDifficultyDialog();
            },
          ),

          const Divider(),

          // Reset progress (disabled in MVP)
          ListTile(
            title: const Text('Reset Progress'),
            subtitle: const Text('Clear all learning data'),
            leading: const Icon(Icons.restart_alt, color: AppColors.error),
            enabled: false,
            onTap: () {
              // This would show a confirmation dialog in the full version
            },
          ),

          // About section
          _buildSectionHeader('About'),

          // App version
          const ListTile(
            title: Text('Version'),
            subtitle: Text('1.0.0'),
            leading: Icon(Icons.info_outline),
          ),

          const Divider(),

          // Privacy policy
          ListTile(
            title: const Text('Privacy Policy'),
            leading: const Icon(Icons.privacy_tip_outlined),
            onTap: () {
              // This would open the privacy policy in the full version
            },
          ),

          const Divider(),

          // Terms of service
          ListTile(
            title: const Text('Terms of Service'),
            leading: const Icon(Icons.description_outlined),
            onTap: () {
              // This would open the terms of service in the full version
            },
          ),

          const SizedBox(height: 24),

          // Feedback button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                _audioService.playButtonSound();
                _showFeedbackDialog();
              },
              icon: const Icon(Icons.feedback_outlined),
              label: const Text('Send Feedback'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Build a section header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // Show difficulty level selection dialog
  void _showDifficultyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Difficulty'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDifficultyOption('Easy', 'Slower pace, more hints'),
            const SizedBox(height: 8),
            _buildDifficultyOption('Medium', 'Balanced learning experience'),
            const SizedBox(height: 8),
            _buildDifficultyOption('Hard', 'Faster pace, fewer hints'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Build a difficulty option
  Widget _buildDifficultyOption(String level, String description) {
    final isSelected = _difficultyLevel == level;

    return InkWell(
      onTap: () {
        _audioService.playButtonSound();
        Navigator.pop(context);
        setState(() {
          _difficultyLevel = level;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(26) : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show feedback dialog
  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Tell us what you think...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _audioService.playButtonSound();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for your feedback!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
